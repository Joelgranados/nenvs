/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "AI agent base dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = [
          pkgs.claude-code
          pkgs.bubblewrap
          pkgs.bash
        ];
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          NIX_ENV_SHELL_ZSHRC_PREFIX="
            ''${NIX_ENV_SHELL_ZSHRC_PREFIX} \
            alias claude='bwrap \
              --die-with-parent \
              --new-session \
              --unshare-pid \
              --share-net \
              --bind ''$(pwd) /sandbox \
              --chdir /sandbox \
              --proc /proc \
              --ro-bind /nix /nix \
              --ro-bind /bin /bin \
              --ro-bind /usr /usr \
              --ro-bind /etc /etc \
              --ro-bind /lib /lib \
              --ro-bind /lib64 /lib64 \
              --dev-bind /dev/null /dev/null \
              --bind /tmp /tmp \
              --bind ~/.claude $HOME/.claude \
              --bind ~/.claude.json $HOME/.claude.json \
              --bind ~/.claude.json.backup $HOME/.claude.json.backup \
              --setenv SHELL "${pkgs.bash}/bin/bash" \
              ${pkgs.claude-code}/bin/claude'
          "
        '';
      };
    };
}
