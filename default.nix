{ pkgs goss_test import <nixpkgs> {} }:

pkgs.callPackage ./derivation.nix {}
