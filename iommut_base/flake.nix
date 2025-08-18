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
          configureFlags = (oldAttrs.configureFlags or []) ++ [
            "--extra-cflags=-DCONFIG_TEST_DEVICES=1"
          ];
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
                  prev.qemu
                  prev.qemu-utils
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
      };

      customLibvfn = libvfn.packages.${system}.default.overrideAttrs (oldAttrs: {
        src = pkgs.fetchgit {
          url = "https://github.com/Joelgranados/libvfn";
          rev = "7766ed4d1fd0e2a73e28b686735cb77abe19ff2b";
          sha256 = "sha256-2tRGGsxrFCai2knO30DNsuGZ9/+YCN2yiUxxR9tV+2A=";
        };
        pname = "libvfn";
      });

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      };
    in
    {
      packages.${system} = {
        qemu-iommut = pkgs.qemu;
        vmctl-iommut = pkgs.vmctl;
        libvfn = customLibvfn;
        default = pkgs.symlinkJoin {
          name = "iommut base testing";
          paths = [ pkgs.qemu pkgs.vmctl customLibvfn ];
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = [
          pkgs.qemu
          pkgs.vmctl
          customLibvfn
          pkgs.virtiofsd
        ];
        packages = self.devShells.${system}.default.shellPkgs;
      };
    };
}

