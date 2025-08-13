{
  description = "iommu testing base env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    libvfn.url = "github:SamsungDS/libvfn";
  };

  outputs = { self, nixpkgs, libvfn, ... }:
    let
      system = "x86_64-linux";

      overlay = final: prev: {
        qemu = prev.qemu.overrideAttrs (oldAttrs: {
          src = prev.fetchurl {
            # Release created with qemu's scripts/archive-source.sh
            url = "https://github.com/Joelgranados/qemu/releases/download/jag%2Fiommut-v20250813/iommut-v20250813.tar.gz";
            sha256 = "sha256:400040b9f251a4724621982ea6840c3f55dad6b88553b1a4537abc79250fa4c5";
          };
          pname = "qemu-iommut";
          patches = [];
        });
        vmctl = prev.vmctl.overrideAttrs (oldAttrs: {
          src = prev.fetchgit {
            url = "https://github.com/Joelgranados/vmctl";
            rev = "97e19f8fd6046f6cbb96064bea823c8dfa562e6f";
            sha256 = "sha256-+29vPc37Jy9nHXvydX3OgNEy0JHq1BmT06XEhuFL/6I=";
          };
          pname = "vmctl-sysctl";
        });

      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };
    in
    {
      packages.${system} = {
        qemu-sysctl = pkgs.qemu;
        vmctl-sysctl = pkgs.vmctl;
        libvfn = libvfn.packages.${system}.default;
        default = pkgs.symlinkJoin {
          name = "iommut base testing";
          paths = [ pkgs.qemu pkgs.vmctl libvfn.packages.${system}.default ];
        };
      };
    };
}

