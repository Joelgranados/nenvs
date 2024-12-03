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
    nixosConfigurations = {
      hobbes = nixpkgs.lib.nixosSystem {
        modules = [
          # FIXME: Avoid hardcoding this!
          /etc/nixos/configuration.nix
          {
            programs.virt-manager.enable = true;

            virtualisation.libvirtd.enable = true;
            virtualisation.spiceUSBRedirection.enable = true;

            users.groups.libvirtd.members = [ "joel" ];
            environment.systemPackages = with pkgs; [
              virt-manager
              spice-vdagent
              spice-gtk
              usbredir
              qemu
              libvirt
            ];
          }
        ];
      };
    };

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
