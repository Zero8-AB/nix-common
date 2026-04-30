{
  description = "Zero8 common nix utilities";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    # deadnix: skip
    self,
    nixpkgs,
    flake-utils,
  }: let
    nix-checks = import ./lib/nix/checks.nix {inherit nixpkgs;};

    dotnet-getruntimeid = import ./lib/dotnet/runtimeid.nix {inherit nixpkgs;};
    nuget-packageslock2nix = import ./lib/dotnet/nuget-packageslock2nix.nix {inherit nixpkgs;};
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          nix
          statix
          deadnix
          alejandra
        ];
      };

      checks = nix-checks system {
        src = ./.;
      };
    })
    // {
      lib = {
        nix = {
          inherit nix-checks;
        };
        dotnet = {
          inherit nuget-packageslock2nix;
          getruntimeid = dotnet-getruntimeid;
        };
      };
    };
}
