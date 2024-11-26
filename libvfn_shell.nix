{ pkgs ? import <nixpkgs> {} }:
let
  def = import ./libvfn.nix { pkgs = pkgs; };
in
  pkgs.mkShell {
    buildInputs = [
      def.libvfn
    ];
  }
