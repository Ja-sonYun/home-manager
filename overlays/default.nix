{ inputs, hostname, ... }:
{
  stable-packages = final: prev: rec {
    # Allow access stable package via `pkgs.stable.<package>`
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };

    # Use stable for commonly broken packages
    gitui = stable.gitui;
    jujutsu = stable.jujutsu;
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

  vim = inputs.vim.overlays.default;
  say = inputs.say.overlays.default;
  plot = inputs.plot.overlays.default;

  tmux-with-sixel = final: prev: {
    tmux = prev.tmux.overrideAttrs (old: {
      configureFlags = (old.configureFlags or [ ]) ++ [ "--enable-sixel" ];
    });
  };

  custom-packages =
    final: prev:
    let
      allhashfile = builtins.fromJSON (builtins.readFile ../pkgs/hashfile.json);
      hashfile = allhashfile."${hostname}";
      callCustomPkg =
        pkgPath:
        final.callPackage pkgPath {
          inherit hashfile;
        };
    in
    {
      custom = {
        ai = callCustomPkg ../pkgs/ai;
        mac = callCustomPkg ../pkgs/mac;
        mcp = callCustomPkg ../pkgs/mcp;
        tmux = callCustomPkg ../pkgs/tmux;
      };
      awscli-local = callCustomPkg ../pkgs/awscli-local;
      git-wrapped = callCustomPkg ../pkgs/git-wrapped;
    };

  # Override upstream packages using our local pkgs/* definitions
  unstable-pkgs-override = final: prev: {
    yabai = final.callPackage ../pkgs/yabai { inherit prev final; };
    jankyborders = final.callPackage ../pkgs/jankyborders { inherit prev final; };
  };
}
