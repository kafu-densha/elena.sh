{
  description = "elena.sh";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      treefmt-nix,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = nixpkgs.lib.singleton (
            final: _prev: {
              prettier-plugin-astro = final.callPackage ./prettier-plugin-astro.nix { };
              prettier-plugin-svelte = final.callPackage ./prettier-plugin-svelte.nix { };
              "elena.sh" = final.callPackage ./default.nix { };
            }
          );
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
              "*.mts"
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

        packages.default = pkgs."elena.sh";

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
