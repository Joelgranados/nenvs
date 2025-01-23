/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "libvfn dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nix_envs?dir=env_shell";
  };

  outputs = { self, nixpkgs, env_shell, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
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
          linuxHeaders
        ];
        hardeningDisable = ["fortify"];

        shellHook = ''
          export _prompt_sorin_prefix="%F{green}(L4N)"
        ''
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
