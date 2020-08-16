{ config, pkgs}:

{
     imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
     ec2.hvm = true;
     environment.systemPackages = with pkgs; [
             htop
             mc
             vim
             ];
 }

