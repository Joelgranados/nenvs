{
  description = "shared environment shell hook";

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellHook = ''
          export _prompt_sorin_prefix="$_prompt_sorin_prefix%F{green}D"
        '';
      };
    };
}
