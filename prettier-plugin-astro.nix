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
  pname = "prettier-plugin-astro";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "withastro";
    repo = "prettier-plugin-astro";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kwNim3u4d4eKneRwyIp+JUQXXxJEdzJJEAlj1sUykU4=";
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
    hash = "sha256-ZQOdrWeLptgPKdfMwfAMY8sjk/+ZwXNBC4M9hYHBFzo=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/prettier-plugin-astro
    cp -r dist/* $out/lib/node_modules/prettier-plugin-astro
    cp -r node_modules $out/lib/node_modules/prettier-plugin-astro

    runHook postInstall
  '';

  meta = {
    description = "Prettier plugin for Astro";
    homepage = "https://github.com/withastro/prettier-plugin-astro";
    license = lib.licenses.mit;
    # maintainers = with lib.maintainers; [ ];
    mainProgram = "prettier-plugin-astro";
  };
})
