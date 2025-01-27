/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "shared environment shell hook";

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellHook = ''
          if [[ ! -v _prompt_sorin_prefix ]]; then
            export _prompt_sorin_prefix="%F{green}D"
          fi
          export SHELL=$(command -v zsh)
          exec $SHELL
        '';
      };
    };
}
