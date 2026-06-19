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
          pkgs.git
          pkgs.notmuch
        ];
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          NIX_ENV_SHELL_ZSHRC_PREFIX="
            ''${NIX_ENV_SHELL_ZSHRC_PREFIX} \
            alias claude='bwrap \
              --die-with-parent \
              --new-session \
              --unshare-pid \
              --unshare-ipc \
              --unshare-uts \
              --unshare-cgroup \
              --share-net \
              --clearenv \
              --setenv HOME "$HOME" \
              --setenv USER "$USER" \
              --setenv SHELL "$SHELL" \
              --setenv COLORTERM truecolor \
              --setenv PATH "/run/current-system/sw/bin:/usr/bin:/bin" \
              --setenv TERM "$TERM" \
              --setenv LANG "$LANG" \
              --setenv LOCALE_ARCHIVE "$LOCALE_ARCHIVE" \
              --setenv SSL_CERT_FILE "$SSL_CERT_FILE" \
              --setenv NIX_SSL_CERT_FILE "$NIX_SSL_CERT_FILE" \
              --bind \''$(pwd) /sandbox/\''$(pwd) \
              --chdir /sandbox/\''$(pwd) \
              --proc /proc \
              --ro-bind /nix /nix \
              --ro-bind /bin /bin \
              --ro-bind /usr /usr \
              --ro-bind /etc /etc \
              --ro-bind /lib /lib \
              --ro-bind /lib64 /lib64 \
              --ro-bind "$HOME"/.gitconfig "$HOME"/.gitconfig \
              --ro-bind "$HOME"/.gitconfig.user "$HOME"/.gitconfig.user \
              --ro-bind "$HOME"/Mail "$HOME"/Mail \
              --ro-bind "$HOME"/.notmuch-config "$HOME"/.notmuch-config \
              --ro-bind "$HOME"/src "$HOME"/src \
              --ro-bind /run/current-system/sw/bin /run/current-system/sw/bin \
              --dev /dev \
              --bind "$HOME"/.claude "$HOME"/.claude \
              --bind "$HOME"/.claude.json "$HOME"/.claude.json \
              --bind "$HOME"/.claude.json.backup "$HOME"/.claude.json.backup \
              ${pkgs.claude-code}/bin/claude'
          "
        '';
      };
    };
}
