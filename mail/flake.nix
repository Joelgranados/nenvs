/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "mail flake";

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
        shellPkgs = with pkgs;
        [
          fzf
          neomutt
          mailcap
          luakit
          isync
          msmtp
          notmuch
          notmuch-mutt
          jq
          w3m
          public-inbox
          abook
          xdg-utils
          zathura
          python311Packages.icalendar
        ];
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          export _prompt_sorin_prefix="%F{green}(MAIL)"

          zdottmp=$(mktemp -d)

          zconffiles="zlogin zlogout zpreztorc zprofile zshenv zshrc"
          for cfile in ''${zconffiles}; do
            echo "source ~/.''${cfile}" >> ''${zdottmp}/.''${cfile}
          done
          ln -s ~/.zprezto ''${zdottmp}/.zprezto

          cat <<EOF >> ''${zdottmp}/.zshrc

          alias mailp='neomutt -F ~/Mail/.config/.muttrc_personal';
          alias mailk='neomutt -F ~/Mail/.config/.muttrc_korg';
          alias mailsyncp='~/Mail/.config/sync.sh';
          alias mailsynck='~/Mail/.config/sync.sh';

          trap 'rm -rf ''${zdottmp}' EXIT
          EOF

          export ZDOTDIR="''${zdottmp}"
        ''
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
