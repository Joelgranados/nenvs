/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "libvfn dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixUpkgs.url =  "github:NixOS/nixpkgs/nixos-unstable";
    env_shell.url = "github:Joelgranados/nenvs?dir=env_shell";
  };

  outputs = { self, nixpkgs, env_shell, nixUpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      uPkgs = import nixUpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          meson
          sparse
          ninja
          gnumake
          bison
          flex
          pahole
          libelf
          elfutils
          ccache
          bc
          gdb
          gcc14
          gnat14
          cpio
          kmod
          zlib
          universal-ctags
          sphinx
          python311Packages.sphinx-rtd-theme
          pkg-config
          libnvme
          clang-tools
          git-filter-repo
          uPkgs.linuxHeaders
        ];
        hardeningDisable = ["fortify"];

        shellHook = ''
          export C_INCLUDE_PATH="${uPkgs.linuxHeaders}/include:$C_INCLUDE_PATH"
          NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(LIBVFN)"

          NIX_ENV_SHELL_ZSHRC_PREFIX="
            cd ~/src/libvfn
          "
        ''
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
