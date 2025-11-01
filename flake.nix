{
  description = "Nix for macOS configuration";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
    ];
  };

  inputs = {
    self.submodules = true;

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-Homebrew to install casks
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    # My packages
    say.url = ./portable/say;
    plot.url = ./portable/plot;
    vim = {
      url = ./portable/vim;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Agenix for secret management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-secrets = {
      url = ./shell/secrets/agenix;
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,

      nixpkgs,
      home-manager,

      nixpkgs-stable,
      home-manager-stable,

      darwin,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,

      vim,
      say,

      agenix,
      agenix-secrets,
      ...
    }:
    let
      specialArgsPrepared = {
        "JasonYuns-MacBook-Pro" = {
          system = "aarch64-darwin";
          username = "jasonyun";
          useremail = "jason@abex.dev";
          hostname = "JasonYuns-MacBook-Pro";
          userhome = "/Users/jasonyun";
          configDir = "/Users/jasonyun/dotfiles";
          cacheDir = "/Users/jasonyun/.nixcache/jasony";
        };
        "JasonYuns-MacBook-Server" = {
          system = "aarch64-darwin";
          username = "jasonyun";
          useremail = "jason@abex.dev";
          hostname = "JasonYuns-MacBook-Server";
          userhome = "/Users/jasonyun";
          configDir = "/Users/jasonyun/dotfiles";
          cacheDir = "/Users/jasonyun/.nixcache/jasony";
        };
        "linux-devel" = {
          system = "x86_64-linux";
          username = "vagrant";
          useremail = "jason@abex.dev";
          hostname = "linux-devel";
          userhome = "/home/vagrant";
          configDir = "/home/vagrant/dotfiles";
          cacheDir = "/home/vagrant/.nixcache/jasony";
        };
        "jason-win" = {
          system = "x86_64-linux";
          username = "jasony";
          useremail = "jason@abex.dev";
          hostname = "jason-win";
          userhome = "/home/jasony";
          configDir = "/home/jasony/dotfiles";
          cacheDir = "/home/jasony/.nixcache/jasony";
        };
      };
      mkSpecialArgs =
        hostname: pkgs:
        let
          specialArgs = specialArgsPrepared."${hostname}";
          system = specialArgs.system;
        in
        {
          inherit system;
          inherit (specialArgs)
            username
            useremail
            hostname
            userhome
            configDir
            cacheDir
            ;
          inherit agenix agenix-secrets;
        };

      mkPkgsProvider =
        system:
        import nixpkgs {
          inherit system;
          overlays = self.overlays;
          config.allowUnfree = true;
        };

      mkHomeManagerConfig =
        hostname:
        let
          specialArgs = specialArgsPrepared."${hostname}";
          system = specialArgs.system;
        in
        [
          # Agenix for secrets management
          agenix.homeManagerModules.default
          # Common configurations
          ./shell
          ./misc/fonts
        ]
        ++ (
          if system == "aarch64-darwin" then
            [
              # Mac os specific configurations
              ./hosts/aarch64-darwin/homemanager.nix
            ]

          else if system == "x86_64-linux" then
            [
              # Linux specific configurations, which isn't implemented yet
              ./hosts/x86_64-linux/homemanager.nix
            ]
          else
            [ ]
        );

      mkX86_64LinuxHomeConfiguration =
        hostname:
        opts@{
          useNvidia ? false,
          isVM ? false,
        }:
        let
          pkgs = mkPkgsProvider system;
          extraSpecialArgs = (mkSpecialArgs hostname pkgs) // opts;
          system = extraSpecialArgs.system;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit extraSpecialArgs pkgs;
          modules = [
            # System configurations
            ./hosts/x86_64-linux/core/nix-core.nix
          ]
          ++ (mkHomeManagerConfig hostname);
        };

      mkAarch64DarwinHomeConfiguration =
        hostname:
        opts@{
          machine ? "main", # "main" or "server"
        }:
        let
          pkgs = mkPkgsProvider system;
          specialArgs = (mkSpecialArgs hostname pkgs) // opts;
          system = specialArgs.system;
        in
        darwin.lib.darwinSystem {
          inherit system specialArgs pkgs;
          modules = [
            # System configurations
            ./hosts/aarch64-darwin/shell.nix

            ./hosts/aarch64-darwin/core/nix-core.nix
            ./hosts/aarch64-darwin/core/system.nix
            ./hosts/aarch64-darwin/core/host-users.nix

            ./hosts/aarch64-darwin/homebrew.nix
            ./hosts/aarch64-darwin/services.nix

            # home manager
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = false;
                extraSpecialArgs = specialArgs;
                users.${specialArgs.username}.imports = mkHomeManagerConfig hostname;
              };
            }

            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = specialArgs.username;
                # Automatically migrate existing Homebrew installations
                autoMigrate = true;
              };
            }
          ];
        };
    in
    {
      darwinConfigurations."JasonYuns-MacBook-Pro" =
        mkAarch64DarwinHomeConfiguration "JasonYuns-MacBook-Pro"
          {
            machine = "main";
          };
      darwinConfigurations."JasonYuns-MacBook-Server" =
        mkAarch64DarwinHomeConfiguration "JasonYuns-MacBook-Server"
          {
            machine = "server";
          };

      homeConfigurations."linux-devel" = mkX86_64LinuxHomeConfiguration "linux-devel" {
        useNvidia = false;
        isVM = true;
      };
      homeConfigurations."jason-win" = mkX86_64LinuxHomeConfiguration "jason-win" {
        useNvidia = true;
        isVM = false;
      };

      overlays = builtins.attrValues (import ./overlays { inherit inputs; });
    };
}
