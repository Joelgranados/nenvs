{
  description = "test flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = with pkgs;
        [
          gnumake
        ];
        packages = self.devShells.${system}.default.shellPkgs;
        shellHook = ''
          echo "I'm in the shell hook"
        '';
      };
    };
}
