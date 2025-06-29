{ inputs, ... }:
{
  stable-packages = final: _prev: {
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
}
