{
  description = "iommu testing base env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    iommutests.url = "github:SamsungDS/iommutests/cdbd312e658d62991c4390f3b478ff3bab457c5a";
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
            url = "${joelgit}/qemu/releases/download/jag%2Fiommut-v20250813/iommut-v20250813.tar.gz";
            sha256 = "sha256:400040b9f251a4724621982ea6840c3f55dad6b88553b1a4537abc79250fa4c5";
          };
          pname = "qemu-iommut";
          patches = [];
        });
        vmctl = prev.vmctl.overrideAttrs (oldAttrs: {
          src = prev.fetchgit {
            url = "https://github.com/SamsungDS/vmctl";
            rev = "a12183b58a48dcba71c9edd9889a7bf067481c70";
            sha256 = "sha256-jH8jNQhfusp5Lkh2o48E/fPOli4lSowfkazNDGsWzHQ=";
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

            # Install config files to etc
            install -Dm644 iommutci.conf -t "$out/etc/iommuci/"
            install -Dm644 iommutci.base.nix -t "$out/etc/iommuci/"

            # Install executable to bin
            install -Dm755 iommutci.test.sh "$out/bin/iommutci.test.sh"

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

