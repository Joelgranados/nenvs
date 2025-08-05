/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "test flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    env_shell.url = "../env_shell";
  };

  outputs = { self, nixpkgs, env_shell, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = with pkgs;
        [
          gnumake
          public-inbox
        ];
        packages = self.devShells.${system}.default.shellPkgs;
        shellHook = ''
          echo "I'm in the shell hook"
          echo $TMPDIR
          NIX_ENV_SHELL_ZSHRC_PREFIX="
            alias lei-stage-a='lei q -v -o ~/Mail/fastmail/lei-staging --dedup=mid -t --no-save -I https://lore.kernel.org/all';
          "
        ''
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
