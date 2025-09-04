{ inputs, ... }:
{
  stable-packages = final: prev: {
    # Allow access stable package via `pkgs.stable.<package>`
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  lib-injection = final: prev: {
    # Inject custom libs into the lib namespace
    lib =
      prev.lib
      // (import ../libs {
        pkgs = final;
        system = final.stdenv.hostPlatform.system;
      });
  };

  neovim = inputs.neovim.overlays.default;

  custom-packages =
    final: prev:
    let
      userhome = "/Users/jasonyun";
    in
    {
      custom = {
        ai = final.callPackage ../pkgs/ai { };
        mac = final.callPackage ../pkgs/mac { };
        mcp = final.callPackage ../pkgs/mcp { inherit userhome; };
        tmux = final.callPackage ../pkgs/tmux { system = final.stdenv.hostPlatform.system; };
      };
    };

  # Override upstream packages using our local pkgs/* definitions
  unstable-pkgs-override = final: prev: {
    yabai = final.callPackage ../pkgs/yabai { inherit prev final; };
    # jankyborders = final.callPackage ../pkgs/jankyborders { inherit prev final; };
  };
}
