{
  lib,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpm_11,
  pnpmConfigHook,
  stdenv,
}:
let
  pnpm = pnpm_11;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "prettier-plugin-svelte";
  version = "4.1.1";

  src = fetchFromGitHub {
    owner = "sveltejs";
    repo = "prettier-plugin-svelte";
    tag = "${finalAttrs.pname}@${finalAttrs.version}";
    hash = "sha256-xgK0LO5iXJRLxS3t0SHmYlrUdB7OQ7IlZWfXm0c1DNo=";
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 5;
    hash = "sha256-+a/NSZVBJgbH8izBmCYnz2TGzK5JzFoAcf75UrzmMSA=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
            runHook preInstall

            mkdir -p $out/lib/node_modules/prettier-plugin-svelte
    	cp plugin.js $out/lib/node_modules/prettier-plugin-svelte/plugin.js
            cp -r node_modules $out/lib/node_modules/prettier-plugin-svelte

            runHook postInstall
  '';

  meta = {
    description = "Prettier plugin for Svelte";
    homepage = "https://github.com/sveltejs/prettier-plugin-svelte";
    license = lib.licenses.mit;
    # maintainers = wisha256-+a/NSZVBJgbH8izBmCYnz2TGzK5JzFoAcf75UrzmMSA=th lib.maintainers; [ ];
    mainProgram = "prettier-plugin-svelte";
  };
})
