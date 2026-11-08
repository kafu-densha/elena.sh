{
  description = "elena.sh";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      treefmt-nix,
      pnpm2nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            pnpm2nix.overlays.default
            (final: _prev: { prettier-plugin-astro = final.callPackage ./prettier-plugin-astro.nix { }; })
            (final: _prev: { prettier-plugin-svelte = final.callPackage ./prettier-plugin-svelte.nix { }; })
          ];
        };

        treefmtConfig = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";

          programs.nixfmt.enable = true;
          programs.deadnix.enable = true;
          programs.statix.enable = true;
          programs.prettier = {
            enable = true;
            settings = {
              tabWidth = 2;
              plugins = [
                "${pkgs.prettier-plugin-astro}/lib/node_modules/prettier-plugin-astro/index.js"
                "${pkgs.prettier-plugin-svelte}/lib/node_modules/prettier-plugin-svelte/plugin.js"
              ];
              overrides = [
                {
                  files = [ "*.astro" ];
                  options.parser = "astro";
                }
                {
                  files = [ "*.svelte" ];
                  options.parser = "svelte";
                }
                {
                  files = [ "*.svg" ];
                  options.parser = "html";
                }
              ];
            };
            includes = [
              "*.astro"
              "*.svelte"
              "*.svg"
            ]
            ++ [
              #defaults
              "*.cjs"
              "*.css"
              "*.html"
              "*.js"
              "*.json"
              "*.json5"
              "*.jsx"
              "*.md"
              "*.mdx"
              "*.mjs"
              "*.scss"
              "*.ts"
              "*.tsx"
              "*.vue"
              "*.yaml"
              "*.yml"
            ];
            excludes = [
              "pnpm-*.yaml"
            ];
          };
        };
      in
      {
        packages.prettier-plugin-astro = pkgs.prettier-plugin-astro;
        packages.prettier-plugin-svelte = pkgs.prettier-plugin-svelte;

        packages.default = pkgs.mkPnpmPackage {
          pname = "elena.sh";
          version = "0.1.0";
          src = ./.;
          packageJSON = ./package.json;
          pnpmLockYaml = ./pnpm-lock.yaml;
          pnpmWorkspaceYaml = ./pnpm-workspace.yaml;
          pnpm = pkgs.pnpm_12;
          inherit (pkgs) nodejs;
        };

        formatter = treefmtConfig.config.build.wrapper;
        checks.formatting = treefmtConfig.config.build.check self;

        devShells.default = pkgs.mkShell {
          shellHook = ''
            # formatting hook
            HOOKS_DIR=$(git rev-parse --git-path hooks)
            mkdir -p $HOOKS_DIR
            cat << 'EOF' > $HOOKS_DIR/pre-commit
            #!/usr/bin/env bash
            exec treefmt --fail-on-change
            EOF
            chmod +x $HOOKS_DIR/pre-commit
          '';
          nativeBuildInputs = [ treefmtConfig.config.build.wrapper ];

          packages = with pkgs; [
            nodejs
            pnpm
          ];
        };
      }
    );
}
