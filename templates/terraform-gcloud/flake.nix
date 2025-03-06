{
  description = "A Nix-flake-based Terraform with Gcloud development environment";

  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
            };
          }
        );
    in
    {
      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              terraform

              google-cloud-sdk
              (google-cloud-sdk.withExtraComponents (
                with google-cloud-sdk.components;
                [
                  gke-gcloud-auth-plugin
                ]
              ))
              kubernetes-helm
            ];
          };
        }
      );
    };
}
