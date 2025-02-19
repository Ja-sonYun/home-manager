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
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-24.11";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.11-darwin";

    agenix.url = "github:ryantm/agenix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Nix-Homebrew to install casks
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
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
      agenix,
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
        "Jasons-MacBook-Pro-2" = {
          system = "aarch64-darwin";
          username = "jasony";
          useremail = "jason@abex.dev";
          hostname = "Jasons-MacBook-Pro-2";
          userhome = "/Users/jasony";
          configDir = "/Users/jasony/dotfiles";
          cacheDir = "/Users/jasony/.nixcache/jasony";
        };
        "Linux" = {
          system = "x86_64-linux";
          username = "jasony";
          useremail = "jason@abex.dev";
          hostname = "Linux";
          userhome = "/home/jasony";
          configDir = "/home/jasony/dotfiles";
          cacheDir = "/Users/jasony/.nixcache/jasony";
        };
      };

    in
    {
      darwinConfigurations."Jasons-MacBook-Pro-2" =
        let
          hostname = "Jasons-MacBook-Pro-2";
          specialArgs = specialArgsPrepared."${hostname}";
          system = specialArgs.system;

          pkgs = import nixpkgs {
            inherit system;

            overlays = self.overlays;
          };

          configPaths =
            [
              # Common configurations
              ./shell
              ./portable
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
        in
        darwin.lib.darwinSystem {
          inherit system specialArgs pkgs;
          modules = [
            # System configurations
            ./shell/system.nix

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
                users.${specialArgs.username}.imports = configPaths;
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

            agenix.nixosModules.default
            {
              environment.systemPackages = [ agenix.packages."${system}".default ];
            }
          ];
        };

      overlays = builtins.attrValues (import ./overlays { inherit inputs; });
    };
}
