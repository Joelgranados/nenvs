/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "iommutests dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    env_shell.url = "github:Joelgranados/nenvs?dir=env_shell";
    iommut_base.url = "github:Joelgranados/nenvs?dir=iommut_base";
    claude.url = "github:Joelgranados/nenvs?dir=claude";
  };

  outputs = { self, nixpkgs, env_shell, iommut_base, claude, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          meson
          ninja
          git
          gnumake
          pkg-config
          cmake
          clang-tools
          bash-language-server
          man-pages
          python3
          (python3.withPackages (ps: with ps; [pytest pyudev]))
          pyright
          git-filter-repo
          clang-tools
          man-pages
          linuxHeaders
        ] ++ claude.devShells.${system}.default.shellPkgs
        ++ iommut_base.devShells.${system}.default.shellPkgs ;
        hardeningDisable = ["fortify"];

        shellHook = ''
          NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(IOMMUT)"

          NIX_ENV_SHELL_ZSHRC_PREFIX="
            cd ~/src/iommutests
          "
        ''
        + iommut_base.devShells.${system}.default.shellHook
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
