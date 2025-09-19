# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ja/jankyborders/package.nix#L43
{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  testers ? null,
  nix-update-script ? null,
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "JankyBorders";
  version = "v1.8.3";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "JankyBorders";
    rev = "1db55bdd4fe80d0ac15d9929d08f10674afa6c89";
    hash = "sha256-lc61PjaRZ8ZOWAFhsf/G3sQkd1oUyePHU43w4pt1AWY=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./bin/borders $out/bin/borders

    runHook postInstall
  '';

  passthru = {
    tests = lib.optionalAttrs (testers != null) {
      version = testers.testVersion {
        package = finalAttrs.finalPackage;
        version = "borders-v${finalAttrs.version}";
      };
    };

    updateScript = if nix-update-script != null then nix-update-script { } else null;
  };

  meta = {
    description = "Lightweight tool designed to add colored borders to user windows on macOS 14.0+";
    longDescription = "It enhances the user experience by visually highlighting the currently focused window without relying on the accessibility API, thereby being faster than comparable tools.";
    homepage = "https://github.com/FelixKratz/JankyBorders";
    license = lib.licenses.gpl3;
    mainProgram = "borders";
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.darwin;
  };
})
