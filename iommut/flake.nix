/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "iommutests dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    libvfn.url = "github:Joelgranados/libvfn/7766ed4d1fd0e2a73e28b686735cb77abe19ff2b";
    env_shell.url = "github:Joelgranados/nenvs?dir=env_shell";
    iommut_base.url = "github:Joelgranados/nenvs?dir=iommut_base";
  };

  outputs = { self, nixpkgs, libvfn, env_shell, iommut_base, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          libvfn.packages.${system}.default
          iommut_base.packages.${system}.default
        ] ++ (with pkgs; [
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
          claude-code
        ]);
        hardeningDisable = ["fortify"];

        shellHook = ''
          NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(IOMMUTESTS)"

          NIX_ENV_SHELL_ZSHRC_PREFIX="
            cd ~/src/iommutests
          "
        ''
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
