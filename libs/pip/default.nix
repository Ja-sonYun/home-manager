{
  mkPipGlobalPackageDerivation =
    {
      pkgs,
      name,
      pythonVersion ? "312",
      packages ? [ ], # List of packages to install, e.g. ["numpy" "pandas" "scipy==1.10.1"]
      exposedBinaries ? [ ],
      buildInputs ? [ ],
      postFixup ?
        {
          python ? null,
        }:
        "",
      outputHash ? null,
      ...
    }:

    let
      pipRequirements = pkgs.lib.concatStringsSep " " packages;
      version = builtins.hashString "sha256" pipRequirements;
      pname = "${name}-${version}";
      targetPythonVersion =
        {
          "312" = "3.12.10";
          "311" = "3.11.8";
        }
        ."${pythonVersion}";
      srcUrl = "https://www.python.org/ftp/python/${targetPythonVersion}/Python-${targetPythonVersion}.tar.xz";
      srcSha256 =
        {
          "https://www.python.org/ftp/python/3.12.10/Python-3.12.10.tar.xz" =
            "sha256-B6tpdHRZXgbwZkdBfTx/qX3tB6/Bp+RFTFY5kZtG6uo=";
        }
        ."${srcUrl}";

      pythonBuild = pkgs.stdenv.mkDerivation {
        name = "python-${targetPythonVersion}";
        src = pkgs.fetchurl {
          url = srcUrl;
          sha256 = srcSha256;
        };

        nativeBuildInputs = with pkgs; [
          pkg-config
          openssl.dev
          zlib.dev
          bzip2
          readline
          ncurses
        ];

        configurePhase = ''
          ./configure --prefix=$out \
                      --with-lto \
                      --with-openssl=${pkgs.openssl.dev} \
                      --with-openssl-rpath=auto \
                      --without-ensurepip
        '';

        buildPhase = "make -j";
        installPhase = "make install";
      };
      tarball = pkgs.stdenv.mkDerivation {
        name = "${pname}-tarball";
        src = pythonBuild;
        doCheck = false;
        dontFixup = true;
        nativeBuildInputs = with pkgs; [
          cacert
          gnutar
        ];
        installPhase = ''
          runHook preInstall

          export HOME=$PWD
          export PATH=$src/bin:$PATH
          mkdir -p wheelhouse

          python3 -m ensurepip --upgrade
          python3 -m pip download --dest wheelhouse ${pipRequirements}

          GZIP=-n tar --sort=name -C wheelhouse -czf wheelhouse.tgz .
          mv wheelhouse.tgz $out

          runHook postInstall
        '';

        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash = if outputHash == null then pkgs.lib.fakeSha256 else outputHash;
      };
    in
    pkgs.stdenv.mkDerivation {
      inherit name version pname;
      src = tarball;
      dontUnpack = true;
      nativeBuildInputs =
        with pkgs;
        [
          gnutar
          pkgs."python${pythonVersion}"
        ]
        ++ buildInputs;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin wheelhouse
        tar -C wheelhouse -xzf $src

        export HOME=$PWD
        python3 -m venv $out/venv/${name}
        source $out/venv/${name}/bin/activate

        pip install --no-index --find-links=wheelhouse ${pipRequirements}

        for bin in ${builtins.concatStringsSep " " exposedBinaries}; do
          ln -s $out/venv/${name}/bin/$bin $out/bin/$bin
        done

        deactivate

        runHook postInstall
      '';
      postFixup =
        ''
          patchShebangs $out
          cd $out
        ''
        + (postFixup {
          python = pkgs."python${pythonVersion}";
        });
    };
}
