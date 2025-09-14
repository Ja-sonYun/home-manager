{ inputs }:
final: prev:
let
  pkgs = prev;
  lib = pkgs.lib;
  python = pkgs.python311;

  # pyproject/uv integration
  workspace = inputs.uv2nix.lib.workspace.loadWorkspace { workspaceRoot = inputs.self; };
  pyOverlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };

  unidicDic = pkgs.stdenv.mkDerivation {
    pname = "unidic";
    version = "3.1.0";
    src = pkgs.fetchzip {
      url = "https://cotonoha-dic.s3-ap-northeast-1.amazonaws.com/unidic-3.1.0.zip";
      sha256 = "sha256-3mMXQrBlyaUqdXv8bsmuI1tr/gPl707qGiduSR4BLtQ=";
    };
    installPhase = ''
      mkdir -p $out/share/unidic
      cp -r * $out/share/unidic
    '';
  };

  mkInjectOverlayFor =
    names: extraInputsFn: f: p:
    lib.genAttrs names (
      name:
      let
        pkg = p.${name} or null;
      in
      if pkg != null && lib.isDerivation pkg && (pkg ? overrideAttrs) then
        pkg.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ (extraInputsFn p);
        })
      else
        p.${name}
    );

  docoptOverlay = mkInjectOverlayFor [ "docopt" ] (p: [ p.setuptools ]);
  jaconvOverlay = mkInjectOverlayFor [ "jaconv" ] (p: [ p.setuptools ]);
  unidicOverlay = mkInjectOverlayFor [ "unidic" ] (p: [ p.setuptools ]);

  pyopenjtalkOverlay = f: p: {
    pyopenjtalk = p.pyopenjtalk.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
        p.setuptools
        p.numpy
        p.cmake
        p.cython
      ];
      env = (old.env or { }) // {
        CYTHONIZE = "1";
      };
    });
  };

  unidicPreinstalledOverlay =
    f: p:
    let
      sp = p.python.sitePackages;
    in
    {
      unidic = p.unidic.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          mkdir -p $out/${sp}/unidic/dicdir
          cp -r ${unidicDic}/share/unidic/* $out/${sp}/unidic/dicdir
          echo "unidic-${unidicDic.version}" > $out/${sp}/unidic/dicdir/version
          echo "# dummy" > $out/${sp}/unidic/dicdir/mecabrc
        '';
        env = (old.env or { }) // {
          FUGASHI_DIC_DIR = "$out/${sp}/unidic/dicdir";
          MECABRC = "$out/${sp}/unidic/dicdir/mecabrc";
        };
      });
    };

  pythonSet =
    (pkgs.callPackage inputs.pyproject-nix.build.packages { inherit python; }).overrideScope
      (
        lib.composeManyExtensions [
          inputs.pyproject-build-systems.overlays.default
          pyOverlay
          docoptOverlay
          jaconvOverlay
          pyopenjtalkOverlay
          unidicOverlay
          unidicPreinstalledOverlay
        ]
      );

  sayEnv = pythonSet.mkVirtualEnv "say-env" workspace.deps.default;

  sayEnvWrapped = pkgs.symlinkJoin {
    name = "say-env-wrapped";
    paths = [ sayEnv ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      libpath="${
        lib.makeLibraryPath [
          pkgs.portaudio
          pkgs.libsndfile
          pkgs.flac
          pkgs.libogg
          pkgs.libvorbis
        ]
      }"
      for bin in python python3; do
        if [ -x "$out/bin/$bin" ]; then
          wrapProgram "$out/bin/$bin" \
            --set DYLD_LIBRARY_PATH "$libpath" \
            --set LD_LIBRARY_PATH   "$libpath"
        fi
      done
    '';
  };

  say = pkgs.stdenv.mkDerivation {
    pname = "say";
    version = "0.1.0";
    src = inputs.self; # repo root must contain say.py
    nativeBuildInputs = [ pkgs.makeWrapper ];
    installPhase = ''
      mkdir -p $out/bin
      makeWrapper ${sayEnvWrapped}/bin/python $out/bin/say \
        --add-flags "$src/say.py" \
        --unset PYTHONPATH
    '';
  };
in
{
  say = say;
  sayEnvWrapped = sayEnvWrapped;
}
