/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "vmctl flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    env_shell.url = "github:Joelgranados/nenvs?dir=env_shell";
  };

  outputs = { self, nixpkgs, env_shell, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = with pkgs;
        [
          virtiofsd
          bash-language-server
          socat
          cdrtools
          bash
          shellcheck

          # For static compile of image-less init
          gcc14
          clang-tools
          gdb
          glibc.static
          dracut
          clang
          musl
        ];
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(VMCTL)"
          NIX_ENV_SHELL_ZSHRC_PREFIX="
            cd ~/src/vmctl
          "
          export VMCTL_VMROOT=$HOME/vms
        ''
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
