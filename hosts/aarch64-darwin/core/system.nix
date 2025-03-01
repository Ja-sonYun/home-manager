{ pkgs, ... }:

###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#
###################################################################################
{
  system = {
    stateVersion = 5;
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      menuExtraClock.Show24Hour = true; # show 24 hour clock

      finder = {
        FXRemoveOldTrashItems = true; # Remove items from the Trash after 30 days
        FXPreferredViewStyle = "clmv"; # Column view
        FXEnableExtensionChangeWarning = false; # Disable warning when changing file extension
        AppleShowAllFiles = true; # Show hidden files
        AppleShowAllExtensions = true; # Show all file extensions
      };

      dock = {
        wvous-tr-corner = 12; # Show notification center
        # Disable hot corner
        wvous-tl-corner = 1;
        wvous-br-corner = 1;
        wvous-bl-corner = 1;

        show-recents = false; # Do not show recent applications in Dock
      };
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;

  # Further configurations are defined in ./shell/system.nix
}
