{ inputs }:
final: prev:
let
  pkgs = prev;
  lib = pkgs.lib;
  python = pkgs.python313;

  workspace = inputs.uv2nix.lib.workspace.loadWorkspace { workspaceRoot = inputs.self; };
  pyOverlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };

  pythonSet =
    (pkgs.callPackage inputs.pyproject-nix.build.packages { inherit python; }).overrideScope
      (
        lib.composeManyExtensions [
          inputs.pyproject-build-systems.overlays.default
          pyOverlay
        ]
      );

  plotEnv = pythonSet.mkVirtualEnv "plot-env" workspace.deps.default;
  plot = pkgs.stdenv.mkDerivation {
    pname = "plot";
    version = "0.1.0";
    src = inputs.self;
    nativeBuildInputs = [ pkgs.makeWrapper ];
    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${plotEnv}/bin/plot $out/bin/plot \
        --unset PYTHONPATH
    '';
  };
in
{
  plot = plot;
}
