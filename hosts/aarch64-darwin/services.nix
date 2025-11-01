{ machine, ... }:
{
  imports = (
    if machine == "main" then
      [
        ./sketchybar/service.nix
        # ./borders/service.nix
        ./yabai/service.nix
        ./skhd/service.nix
      ]
    else
      [ ]
  );
}
