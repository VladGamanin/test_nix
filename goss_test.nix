{ lib
, stdenv
, fetchurl
, gcc-unwrapped
, dpkg
, polkit
, bash
}:

let
  libPath = lib.makeLibraryPath [
    # for libstdc++.so.6
    gcc-unwrapped.lib
  ];

  sha256 = {
    "x86_64-linux" = "c8d81ba0c808d11c7cc996fa73c583f3d12b954884a9de696f5df09b7f223f30";
    "i686-linux" = "0wsv4mvwrvsaz1pwiqs94b3854h5l8ff2dbb1ybxmvwjbfrkdcqc";
  }."${stdenv.system}";

  arch = {
    "x86_64-linux" = "amd64";
    "i686-linux" = "i386";
  }."${stdenv.system}";

in stdenv.mkDerivation rec {
  pname = "goss_test";
  version = "0.2.4.1";

  src = fetchurl {
    url = "https://github.com/VladGamanin/test_nix/releases/download/0.1/goss_${version}_${arch}.deb";
    inherit sha256;
  };

  buildInputs = [
    gtk3
  ];

  nativeBuildInputs = [
    wrapGAppsHook
  ];

  dontBuild = true;
  dontConfigure = true;

  unpackPhase = ''
    ${dpkg}/bin/dpkg-deb -x $src .
  '';

  # sudo-prompt has hardcoded binary paths on Linux and we patch them here
  # along with some other paths
  patchPhase = ''
    ${nodePackages.asar}/bin/asar extract opt/balenaEtcher/resources/app.asar tmp
    # Use Nix(OS) paths
    sed -i "s|/usr/bin/pkexec|/usr/bin/pkexec', '/run/wrappers/bin/pkexec|" tmp/node_modules/sudo-prompt/index.js
    sed -i 's|/bin/bash|${bash}/bin/bash|' tmp/node_modules/sudo-prompt/index.js
    sed -i "s|process.resourcesPath|'$out/opt/balenaEtcher/resources/'|" tmp/generated/gui.js
    ${nodePackages.asar}/bin/asar pack tmp opt/balenaEtcher/resources/app.asar
    rm -rf tmp
    # Fix up .desktop file
    substituteInPlace usr/share/applications/balena-etcher-electron.desktop \
      --replace "/opt/balenaEtcher/balena-etcher-electron" "$out/bin/balena-etcher-electron"
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r opt $out/
    cp -r usr/share $out/
    # We'll use our Nixpkgs electron_3 instead
    rm $out/opt/balenaEtcher/balena-etcher-electron
    ln -s ${electron_3}/bin/electron $out/bin/balena-etcher-electron
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --add-flags $out/opt/balenaEtcher/resources/app.asar
      --prefix LD_LIBRARY_PATH : ${libPath}
    )
  '';

  meta = with stdenv.lib; {
    description = "test make nix package";
    homepage = "https://etcher.io/";
    license = licenses.asl20;
    maintainers = [ maintainers.shou ];
    platforms = [ "i686-linux" "x86_64-linux" ];
  };
}

