{
  description = "kdevops dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nix_envs?dir=env_shell";
    env_kernel.url = "github:Joelgranados/nix_envs?dir=kernel";

  };

  outputs = { self, nixpkgs, env_shell, env_kernel, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {

        shellPkgs = with pkgs;
        [
        ] ++ env_kernel.devShells.${system}.default.shellPkgs ;
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
        ''
        + env_kernel.devShells.${system}.default.shellHook ;
      };
    };
}
