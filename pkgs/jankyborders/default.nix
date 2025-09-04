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
  version = "main";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "JankyBorders";
    rev = "f969290911875d74d24bc74861c527e0b175a8a9";
    hash = "sha256-PUyq3m244QyY7e8+/YeAMOxMcAz3gsyM1Mg/kgjGVgU=";
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
