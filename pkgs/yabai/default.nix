{ stdenvNoCC, lib, ... }:

stdenvNoCC.mkDerivation {
  pname = "yabai";
  version = "ff42cea";
  src = ./yabai-bin;
  dontUnpack = true;

  installPhase = ''
    mkdir -p "$out/bin"
    cp "$src" "$out/bin/yabai"
    chmod +x "$out/bin/yabai"
  '';

  meta = with lib; {
    description = "";
    platforms = platforms.darwin;
    homepage = "https://github.com/koekeishiya/yabai";
  };
}
