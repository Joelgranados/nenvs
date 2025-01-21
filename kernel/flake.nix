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
            host=$1
            shift 1;
            PWD=$(pwd)
            cmd="ssh $host \"(cd $PWD && nix develop github:Joelgranados/nix_envs\?dir=_kernel --command $@)\""
            echo $cmd
            eval $cmd
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
