{
  mkNpmGlobalPackageDerivation =
    {
      pkgs,
      name,
      system,
      packages ? [ ], # List of packages to install, e.g. ["npm" "yarn" "express@latest"]
      exposedBinaries ? [ ],
      outputHash ? null,
      nodeVersion ? "22",
      ...
    }:
    let
      packagesRequirements = pkgs.lib.concatStringsSep " " packages;
      version = builtins.hashString "sha256" packagesRequirements;
      pname = "${name}-${version}";
      targetNodeVersion =
        {
          "22" = "22.15.1";
        }
        ."${nodeVersion}";
      targetSystem =
        {
          "aarch64-darwin" = "darwin-arm64";
          "x86_64-darwin" = "darwin-x64";
          "x86_64-linux" = "linux-x64";
        }
        ."${system}";
      url = "https://nodejs.org/dist/v${targetNodeVersion}/node-v${targetNodeVersion}-${targetSystem}.tar.gz";
      sha256 =
        {
          "https://nodejs.org/dist/v22.15.1/node-v22.15.1-darwin-arm64.tar.gz" =
            "sha256-0mibhrF+G1Hnb4Af/i2azKQiXnbtpLhDw9hDjUp81v4=";
        }
        ."${url}";
      nodeBinary = pkgs.stdenv.mkDerivation {
        name = "node-${targetNodeVersion}";
        src = pkgs.fetchurl {
          url = url;
          sha256 = sha256;
        };
        installPhase = ''
          runHook preInstall

          mkdir -p $out
          tar -C $out --strip-components=1 -xzf $src

          runHook postInstall
        '';
      };
      tarball = pkgs.stdenv.mkDerivation {
        name = "${pname}-tarball";
        src = nodeBinary;
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
          export CACHE=$HOME/cache

          npm install --ignore-scripts --no-audit --no-fund \
              --cache "$CACHE" \
              ${packagesRequirements}

          GZIP=-n tar --sort=name -C "$CACHE" -czf npm-cache.tgz "$CACHE" .
          mv npm-cache.tgz $out

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
      nativeBuildInputs = with pkgs; [
        gnutar
        nodeBinary
      ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/bin $out/node_modules/${name}
        export HOME=$PWD
        export NODE_PATH=$out/node_modules/${name}
        export NPM_CONFIG_CACHE=$HOME/cache

        mkdir -p $NPM_CONFIG_CACHE
        tar -C $NPM_CONFIG_CACHE -xzf $src

        npm install -g --prefix $NODE_PATH ${packagesRequirements} --offline --ignore-scripts

        for bin in ${builtins.concatStringsSep " " exposedBinaries}; do
          ln -s $NODE_PATH/bin/$bin $out/bin/$bin
        done

        runHook postInstall
      '';
      postFixup = ''
        # Patch every shebang inside $out to use store path node
        patchShebangs $out
      '';
    };
}
