{
  description = "Security Analysis";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      ...
    }:
    let
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      getPackages = system: {
        pkgs = import nixpkgs { inherit system; };
        unstablePkgs = import nixpkgs-unstable { inherit system; };
      };

      commonPackages =
        { pkgs, unstablePkgs }:
        with unstablePkgs;
        [
          git
          cacert

          # Python 3.12
          python312
          python312Packages.pip
          python312Packages.setuptools
          python312Packages.wheel

          # Debugging
          cargo-flamegraph

          # Code
          pmd

          # Binary analysis
          radare2
          rizin

          # Cloud Infrastructure
          checkov
          trivy

          # API Related
          nmap
          sqlmap

          # API - Fuzz
          wfuzz
          ffuf
          gospider
          arjun

          # Network
          trippy

          # JWT
          jwt-cli
          jwt-hack

          # Packet
          tcpdump
          tshark
          # Won't install gui version
          # wireshark

          # Password
          john
        ]
        ++ pkgs.lib.optional (system == "x86_64-linux") [
          rr
          gdb
        ];

      envSetup = pkgs: ''
        _NIX_INSTALATION_DIR=$HOME/.nixcache/$(whoami)/analysis
        export _NIX_INSTALATION_DIR
        mkdir -p "$_NIX_INSTALATION_DIR"
        export XDG_CONFIG_HOME=${./configs}
        export PATH="$PATH:${./scripts}"
      '';

      mkDevShell =
        system:
        let
          p = getPackages system;
          env = envSetup p.pkgs;
        in
        p.pkgs.mkShell {
          packages = commonPackages { inherit (p) pkgs unstablePkgs; };

          shellHook = ''
            ${env}

            echo "Welcome to the dev shell for ${system}!"
          '';
        };
    in
    {
      devShells = builtins.listToAttrs (
        map (system: {
          name = system;
          value = {
            default = mkDevShell system;
          };
        }) systems
      );
    };
}
