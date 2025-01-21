{
  description = "kernel shell dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nix_envs?dir=env_shell";
    env_kernel.url = "github:Joelgranados/nix_envs?dir=_kernel";
  };

  outputs = { self, nixpkgs, env_shell, env_kernel, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          (pkgs.writeShellScriptBin "k4l" ''
            #!/usr/bin/env bash

            BASENAME="$(basename "''${BASH_SOURCE[0]}")"
            USAGE="Usage: ''${BASENAME} HOST COMMAND\n
              HOST      Name of ssh-able host\n
              COMMAND   Command to append\n
            "

            if [ $# -lt 2 ]; then
              echo -e ''${USAGE}
              exit 1
            fi
            HOST=$1
            shift 1;
            PWD=$(pwd)
            KERN_URL="github:Joelgranados/nix_envs\?dir=_kernel"
            CMD="ssh ''${HOST} \"(cd ''${PWD} && nix develop ''${KERN_URL} --command $@)\""
            echo ''${CMD}
            eval ''${CMD}
          '')
        ] ++ env_kernel.devShells.${system}.default.shellPkgs ;

        shellHook = ''
          if [[ ! -v _prompt_sorin_prefix ]]; then
            export _prompt_sorin_prefix="%F{green}(K4L)"
          fi
        ''
        + env_kernel.devShells.${system}.default.shellHook
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
