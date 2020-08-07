{ stdenv, dpkg, glibc, gcc-unwrapped, autoPatchelfHook, fetchurl }:
let

  # Please keep the version x.y.0.z and do not update to x.y.76.z because the
  # source of the latter disappears much faster.
  version = "0.0.1";

  sha256 = {
    "x86_64-linux" = "c8d81ba0c808d11c7cc996fa73c583f3d12b954884a9de696f5df09b7f223f30";    
  }."${stdenv.system}";

  src =  fetchurl {
    url = "https://github.com/VladGamanin/test_nix/releases/download/0.1/goss_${version}_${arch}.deb";
    inherit sha256;
  };

in stdenv.mkDerivation {
  name = "goss_test-${version}";

  system = "x86_64-linux";

  
  # Required for compilation
  nativeBuildInputs = [
    autoPatchelfHook # Automatically setup the loader, and do the magic
    dpkg
  ];

  # Required at running time
  buildInputs = [
    glibc
    gcc-unwrapped
  ];

  unpackPhase = "true";

  # Extract and copy executable in $out/bin
  installPhase = ''
    mkdir -p $out
    dpkg -x $src $out
    cp -av $out/opt/Wolfram/WolframScript/* $out
    rm -rf $out/opt
  '';

  meta = with stdenv.lib; {
    description = "goss_test";
    homepage = https://goss/test;
    license = licenses.mit;
    maintainers = with stdenv.lib.maintainers; [ ];
    platforms = [ "x86_64-linux" ];
  };
