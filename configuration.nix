{
     imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
     ec2.hvm = true;
 }

 {pkgs = import <nixpkgs> {};
     
     environment.systemPackages = with pkgs; [
             htop
             mc
             vim
             ];
}
