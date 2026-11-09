{
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
  pname = "elena.sh";
  version = "0.1.0";
  src = ./.;

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 5;
    hash = "sha256-XK1uLQoRXSj7JCp5/NpK3CJRQxWFWZX+JyjTqKpKQjI=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r dist/* $out

    runHook postInstall
  '';
})
