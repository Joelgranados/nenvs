{
  description = "kernel dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nix_envs?dir=env_shell";
    env_ccache.url = "github:Joelgranados/nix_envs?dir=ccache";
  };

  outputs = { self, nixpkgs, env_shell, env_ccache, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = with pkgs;
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
        ] ++ env_ccache.devShells.${system}.default.shellPkgs ;
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          if [[ ! -v _prompt_sorin_prefix ]]; then
            export _prompt_sorin_prefix="%F{green}(K4L)"
          fi
        ''
        + env_ccache.devShells.${system}.default.shellHook
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
