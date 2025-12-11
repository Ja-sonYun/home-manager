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
    else if machine == "server" then
      [
        ../../infra/service/aarch64-darwin
      ]
    else
      [ ]
  );
}
