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
          (pkgs.writeShellScriptBin "krc" ''
            #!/usr/bin/env bash
            PWD=$(pwd)
            KERN_URL="github:Joelgranados/nix_envs\?dir=_kernel"
            BASENAME="$(basename "''${BASH_SOURCE[0]}")"
            USAGE="\nUsage: ''${BASENAME} <HOST> <COMMAND>\n
              HOST      Name of ssh-able host\n
              COMMAND   Command to append\n\n
            Note: A mutagen session for $pwd must exist."

            mutagen_sync() {
              local sess=$1
              local cmd="mutagen sync resume ''${sess} \
                && mutagen sync flush ''${sess} \
                && mutagen sync pause ''${sess}"
              echo ''${cmd}; eval ''${cmd}
              if [ $? != 0 ]; then # FIXIT: Extend to check for host equivalence
                echo -e ''${USAGE}; exit 1
              fi
            }

            if [ $# -lt 2 ]; then
              echo -e ''${USAGE}; exit 1
            fi
            HOST=$1; shift 1;
            MUT_SESS_NAME="$(pwd | sed "s./..g")''${HOST}"

            mutagen_sync ''${MUT_SESS_NAME}

            CMD="ssh ''${HOST} \"(cd ''${PWD} && nix develop ''${KERN_URL} --command $@)\""
            echo ''${CMD}; eval ''${CMD}

            mutagen_sync ''${MUT_SESS_NAME}
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
