/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "VDI flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
  {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      pname = "vdictrl";
      version = "0.0.1";
      src = ./.;
      installPhase = ''
        mkdir -p $out/bin
        cp vdictrl.sh $out/bin/vdictrl
        chmod +x $out/bin/vdictrl
      '';
    };

    devShells.${system}.default = pkgs.mkShell {
      buildInputs = [ self.packages.${system}.default ]
      ++ (with pkgs;
      [
        virt-manager
        spice-vdagent
        spice-gtk
        usbredir
        qemu_kvm
        libvirt
      ]);

      shellHook = ''
        alias vdi_start='vdictrl -n win11 -a start'
        alias vdi_stop='vdictrl -n win11 -a stop'
        alias vdi_suspend='vdictrl -n win11 -a suspend'
        alias vdi_resume='vdictrl -n win11 -a resume'

        ${./vdictrl.sh} -n win11 -a start
        trap '${./vdictrl.sh} -n win11 -a stop' EXIT
      ''
      ;
    };
  };
}
