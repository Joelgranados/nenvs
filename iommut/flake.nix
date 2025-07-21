/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "iommutests dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    libvfn.url = "github:Joelgranados/libvfn/d511b650cdc26bc00fbf2ea8cf5684cc952af4e4";
    env_shell.url = "github:Joelgranados/nenvs?dir=env_shell";
  };

  outputs = { self, nixpkgs, libvfn, env_shell, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          libvfn.packages.${system}.default
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
        ];
        hardeningDisable = ["fortify"];

        shellHook = ''
          export C_INCLUDE_PATH="${pkgs.linuxHeaders}/include:$C_INCLUDE_PATH"
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
