{ userhome, username, pkgs, lib, config, ... }:
{
  home.file."alacritty.toml" = {
    target = ".config/alacritty/alacritty.toml";
    source = toString ./alacritty.toml;
  };
}
