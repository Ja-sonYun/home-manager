{
  description = "Nix for macOS configuration";

  nixConfig = {
    substituters = [
      # Query the mirror of USTC first, and then the official cache.
      "https://cache.nixos.org"
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix-Homebrew to install casks
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
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

    neovim.url = "path:./portable/neovim";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      darwin,
      home-manager,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      neovim,
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
          libs = import ./libs;
        };
        "linux-devel" = {
          system = "x86_64-linux";
          username = "vagrant";
          useremail = "jason@abex.dev";
          hostname = "linux-devel";
          userhome = "/home/vagrant";
          configDir = "/home/vagrant/dotfiles";
          cacheDir = "/home/vagrant/.nixcache/jasony";
          libs = import ./libs;
        };
        "jason-win" = {
          system = "x86_64-linux";
          username = "jasony";
          useremail = "jason@abex.dev";
          hostname = "jason-win";
          userhome = "/home/jasony";
          configDir = "/home/jasony/dotfiles";
          cacheDir = "/home/jasony/.nixcache/jasony";
          libs = import ./libs;
        };
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
          # Common configurations
          ./shell
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
          extraSpecialArgs = specialArgsPrepared."${hostname}" // opts;
          system = extraSpecialArgs.system;
          pkgs = mkPkgsProvider system;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit extraSpecialArgs pkgs;
          modules = [
            # System configurations
            ./hosts/x86_64-linux/core/nix-core.nix
          ] ++ (mkHomeManagerConfig hostname);
        };
    in
    {
      darwinConfigurations."JasonYuns-MacBook-Pro" =
        let
          hostname = "JasonYuns-MacBook-Pro";
          specialArgs = specialArgsPrepared."${hostname}";
          system = specialArgs.system;
          pkgs = mkPkgsProvider system;
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
