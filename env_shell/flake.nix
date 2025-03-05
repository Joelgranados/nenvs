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
          if [[ ! -v NIX_ENV_SHELL_PROMPT_PREFIX ]]; then
            NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}D"
          fi

          zdottmp=$(mktemp -d)

          zconffiles="zlogin zlogout zpreztorc zprofile zshenv zshrc"
          for cfile in ''${zconffiles}; do
            echo "source ~/.''${cfile}" >> ''${zdottmp}/.''${cfile}
          done
          ln -s ~/.zprezto ''${zdottmp}/.zprezto
          ln -s ~/.zsh_history ''${zdottmp}/.zsh_history

          cat <<EOF >> ''${zdottmp}/.zshrc
          ''${NIX_ENV_SHELL_ZSHRC_PREFIX}
          RPROMPT=''$NIX_ENV_SHELL_PROMPT_PREFIX
          trap 'rm -rf ''${zdottmp}' EXIT
          EOF

          export ZDOTDIR="''${zdottmp}"

          export SHELL=$(command -v zsh)
          exec $SHELL
        '';
      };
    };
}
