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
      aigentPath = "/run/current-system/sw/bin:/usr/bin:/bin";
    in {
      inherit aigentPath;

      packages.${system}.claude = pkgs.claude-code;

      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = [
          pkgs.claude-code
          pkgs.bubblewrap
          pkgs.bash
          pkgs.git
        ];
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          NIX_ENV_SHELL_ZSHRC_PREFIX="
            ''${NIX_ENV_SHELL_ZSHRC_PREFIX} \
            alias sb_claude='bwrap \
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
              --setenv PATH "${aigentPath}" \
              --setenv TERM "$TERM" \
              --setenv LANG "$LANG" \
              --setenv LOCALE_ARCHIVE "$LOCALE_ARCHIVE" \
              --bind \''$(pwd) /sandbox/\''$(pwd) \
              --chdir /sandbox/\''$(pwd) \
              --proc /proc \
              --ro-bind /nix /nix \
              --ro-bind /bin /bin \
              --ro-bind /usr /usr \
              --ro-bind /etc /etc \
              --ro-bind /lib /lib \
              --ro-bind /lib64 /lib64 \
              --ro-bind /run/current-system/sw/bin /run/current-system/sw/bin \
              --ro-bind "$HOME"/.gitconfig "$HOME"/.gitconfig \
              --ro-bind "$HOME"/.gitconfig.user "$HOME"/.gitconfig.user \
              --dev /dev \
              --dir "$HOME" \
              --overlay-src "$HOME/.claude" \
              --tmp-overlay "$HOME/.claude" \
              --file 4 "$HOME/.claude.json" \
              --file 5 "$HOME/.claude.json.backup" \
              4< "$HOME/.claude.json" \
              5< "$HOME/.claude.json.backup"'
          "
        '';
      };
    };
}
