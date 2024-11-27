{
  description = "kernel dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
      shell_vars = import ../env_shell/env_shell.nix;
      ccache_vars = import ../ccache/ccache.nix { inherit pkgs; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs;
        [
          gnumake
          bison
          flex
          ncurses
          (pkgs.python3.withPackages (ppkgs: [
            ppkgs.alabaster
            ppkgs.sphinx
            ppkgs.pyyaml
          ]))
          pahole
          elfutils
          bc
          gdb
          openssl
          gcc14
          cpio
          kmod
          zlib
          clang-tools
          coccinelle
          man-pages
          clang-tools
          git-filter-repo
          git
          pkg-config
        ] ++ ccache_vars.packageList;

        shellHook = ''
          ${ccache_vars.shellHook}
          ${shell_vars.shellHook}
        '';
      };
    };
}
