{
  description = "iommu continuous integration environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    iommutests.url = "github:SamsungDS/iommutests/2e1cee880076607a334085faad88a242f9e3e745";
  };

  outputs = { self, nixpkgs, iommutests, ... }:
    let
      system = "x86_64-linux";
      joelgit = "https://github.com/Joelgranados";

      overlay = final: prev: {
        customKernel = (prev.linuxPackages_custom {
          src = prev.fetchgit {
            url = "${joelgit}/linux";
            rev = "46bfe732f05e978dde094451887a325884082788";
            sha256 = "sha256-vm8nwEDiOmVRyU/wxe47ZsZyEhxiKf/A2qHI26Kf83I=";
          };
          version = "6.15-custom";
          modDirVersion = "6.15.0";
          configfile = ./kernel.conf;
        }).kernel;
        qemu = prev.qemu.overrideAttrs (oldAttrs: {
          src = prev.fetchurl {
            # Release created with qemu's scripts/archive-source.sh
            url = "${joelgit}/qemu/releases/download/jag%2Fiommut-v20250909/iommut-v20250909.tar.gz";
            sha256 = "sha256:4440d9ebe2061db3984ca39ca8fd2f914729c65734ac582875f5b2c125975d87";
          };
          pname = "qemu-iommut";
          patches = [];
          configureFlags = (oldAttrs.configureFlags or []) ++ [
            "--target-list=x86_64-softmmu,aarch64-softmmu"
          ];
        });
        vmctl = prev.vmctl.overrideAttrs (oldAttrs: {
          src = prev.fetchgit {
            url = "https://github.com/SamsungDS/vmctl";
            rev = "df1cd750366c8cfb45716795c4885221c131a22b";
            sha256 = "sha256-Kjc0TxA3I4wIGvh8imwNTg+EgeEH/pqe6F6dv2cpODk=";
          };
          pname = "vmctl-iommut";
          installPhase = ''
            runHook preInstall

            install -Dm555 vmctl -t "$out/bin"
            wrapProgram "$out/bin/vmctl" \
              --set PATH "${
                prev.lib.makeBinPath [
                  prev.openssh
                  prev.socat
                  prev.gawk
                  prev.cloud-utils
                  prev.cdrtools
                  final.qemu
                  final.qemu-utils
                  prev.coreutils
                  prev.getopt

                  # Additional deps for new vmctl
                  prev.virtiofsd
                  prev.nix
                  prev.gnumake
                  prev.gcc
                  prev.gnused
                  prev.bash
                  prev.glibc.static
                  prev.clang
                  prev.musl.dev
                  prev.cpio
                  prev.findutils
                  prev.procps
                  prev.gnugrep
                ]
              }"

            cp -r {cmd,common,contrib,lib} $out
            runHook postInstall
          '';
        });
        iommuci = prev.stdenv.mkDerivation {
          pname = "iommuci";
          version = "0.0.1";

          src = ./.;

          installPhase = ''
            runHook preInstall

            install -Dm644 iommuci.nix -t "$out/etc/iommuci/"
            sed "s|: ...GUEST_KERNEL_CUSTOM_DIR:=.*|GUEST_KERNEL_CUSTOM_DIR=${final.customKernel}|" \
                iommuci.conf | install -Dm644 /dev/stdin "$out/etc/iommuci/iommuci.conf"
            sed "s|: ...CONFDIR:=.*|CONFDIR=$out/etc/iommuci|" \
                iommuci.sh | install -Dm755 /dev/stdin "$out/bin/iommuci"

            runHook postInstall
          '';
        };
      };

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };
    in
    {
      packages.${system} = {
        qemu-iommut = pkgs.qemu;
        vmctl-iommut = pkgs.vmctl;
        customKernel = pkgs.customKernel;
        iommuci = pkgs.iommuci;
        default = pkgs.symlinkJoin {
          name = "iommut base testing";
          paths = [ pkgs.qemu pkgs.vmctl pkgs.iommuci ];
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = [
          iommutests.packages.${system}.default
          pkgs.qemu
          pkgs.vmctl
          pkgs.virtiofsd
          pkgs.customKernel
          pkgs.iommuci
        ];
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          echo "Kernel package ${pkgs.customKernel}"
        '';
      };
    };
}

