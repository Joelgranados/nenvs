/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "mail flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nenvs?dir=env_shell";
    aiagent_base.url = "github:Joelgranados/nenvs?dir=aiagent_base";
  };

  outputs = { self, nixpkgs, env_shell, aiagent_base, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "lei-q-db";
        version = "0.0.1";
        src = ./.;
        installPhase = ''
          mkdir -p $out/bin
          cp lei-q-db $out/bin/lei-q-db
          chmod +x $out/bin/lei-q-db
        '';
      };

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
        packages = self.devShells.${system}.default.shellPkgs
          ++ aiagent_base.devShells.${system}.default.shellPkgs
          ++ [self.packages.${system}.default];

        shellHook = ''
          NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(MAIL)"
          NIX_ENV_SHELL_ZSHRC_PREFIX="
            alias mailp='neomutt -F ~/Mail/.config/.muttrc_personal';
            alias mailk='neomutt -F ~/Mail/.config/.muttrc_korg';
            alias mailt='neomutt -F ~/Mail/.config/.muttrc_test';
            alias mailsyncp='~/Mail/.config/sync.sh';
            alias mailsynck='~/Mail/.config/sync.sh';
            alias lei-stage-a='lei q -v -o ~/Mail/fastmail/lei-staging --dedup=mid -t --no-save -I https://lore.kernel.org/all';
            alias lei-stage='lei q -v -o ~/Mail/fastmail/lei-staging --dedup=mid -t --no-save';

            # Avoid confusions about where the tmpdir is. It will restart with lei cmd
            lei daemon-kill
          "
        ''
        + aiagent_base.devShells.${system}.default.shellHook
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
