/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "VDI flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in
  {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs;
      [
        virt-manager
        spice-vdagent
        spice-gtk
        usbredir
        qemu_kvm
        libvirt
      ];

      shellHook = ''
        ${./vdictrl.sh} -n win11 -a start
        trap '${./vdictrl.sh} -n win11 -a stop' EXIT
      ''
      ;
    };
  };
}
