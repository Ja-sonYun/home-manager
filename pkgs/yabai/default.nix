{ stdenvNoCC, lib, ... }:

stdenvNoCC.mkDerivation {
  pname = "yabai";
  version = "tahoe-beta9";
  src = ./yabai;
  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/bin"
    cp "$src" "$out/bin/yabai"
    chmod +x "$out/bin/yabai"
  '';

  meta = with lib; {
    description = "Yabai tahoe-beta9 binary override";
    platforms = platforms.darwin;
    homepage = "https://github.com/koekeishiya/yabai";
  };
}
