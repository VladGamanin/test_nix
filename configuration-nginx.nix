{ config, pkgs, services,...}:
{
imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
     ec2.hvm = true;
     environment.systemPackages = with pkgs; [
             htop
             mc
             vim

             ];
security.acme.acceptTerms = true;
security.acme.email = "admin+acme@shadowside.tk";
services.nginx = {
  enable = true;
  virtualHosts."shadowside.tk" = {
    enableACME = true;
    forceSSL = true;
    root = "/var/www/shadowside.tk";
  };
};
# Optional: You can configure the email address used with Let's Encrypt.
# This way you get renewal reminders (automated by NixOS) as well as expiration emails.
security.acme.certs = {
  "shadowside.tk".email = "admin@shadowside.tk";
};

}
