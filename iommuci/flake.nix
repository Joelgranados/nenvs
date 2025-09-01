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
        customKernelSrc = prev.fetchgit {
          url = "${joelgit}/linux";
          rev = "0ff41df1cb268fc69e703a08a57ee14ae967d0ca";
          sha256 = "sha256-PQjXBWJV+i2O0Xxbg76HqbHyzu7C0RWkvHJ8UywJSCw=";
        };
        customKernel = prev.linuxKernel.kernels.linux_6_12.override {
          src = final.customKernelSrc;
          version = "6.12-custom";
          modDirVersion = "6.12.0-custom";
          structuredExtraConfig = with prev.lib.kernel; {
            # VirtioFS support
            VIRTIO_FS = yes;
            FUSE_FS = yes;
            VIRTIO = yes;
            VIRTIO_PCI = yes;
            VIRTIO_MMIO = yes;

            # RAM disk support
            BLK_DEV_RAM = yes;
            BLK_DEV_RAM_COUNT = freeform "16";
            BLK_DEV_RAM_SIZE = freeform "65536";

            TMPFS = yes;
            TMPFS_POSIX_ACL = yes;
          };
        };
        qemu = prev.qemu.overrideAttrs (oldAttrs: {
          src = prev.fetchurl {
            # Release created with qemu's scripts/archive-source.sh
            url = "${joelgit}/qemu/releases/download/jag%2Fiommut-v20250901/iommut-v20250901.tar.gz";
            sha256 = "sha256:5027cb4e56c85e15008348a4a94c4c7fb066b5aa17210b3991bc0857c7fac108";
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
            rev = "c02f41960af42396904ce323ce9f74b2e7930bff";
            sha256 = "sha256-8MG+2TQNIlM8WTNHvmVtgtbDZ9rjVDIMe4z6N6s1Qkg=";
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

