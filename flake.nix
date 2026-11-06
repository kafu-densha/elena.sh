{
  description = "elena.sh";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    flake-utils.url = "github:numtide/flake-utils";
    pnpm2nix = {
      url = "github:FliegendeWurst/pnpm2nix-nzbr";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pnpm2nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            pnpm2nix.overlays.default
          ];
        };
      in
      {
        packages.default = pkgs.mkPnpmPackage {
          pname = "elena.sh";
          version = "0.1.0";
          src = ./.;
          packageJSON = ./package.json;
          pnpmLockYaml = ./pnpm-lock.yaml;
          pnpmWorkspaceYaml = ./pnpm-workspace.yaml;
          nodejs = pkgs.nodejs;
          pnpm = pkgs.pnpm;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nodejs
            pnpm
          ];
        };
      }
    );
}
