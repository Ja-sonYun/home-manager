{
  mkCargoGlobalPackageDerivation =
    {
      pkgs,
      name,
      version ? "latest",
      rustEdition ? "2021",
      outputHash ? null,
      ...
    }:

    let
      pname = "${name}@${version}";
      packageRequest = if version == "latest" then name else pname;
      # NOTE: You can find the versions info here:
      # https://forge.rust-lang.org/infra/other-installation-methods.html#which
      rustToolchain =
        {
          "2021" = "1.75.0"; # Rust2021
          "2024" = "1.85.0";
        }
        ."${rustEdition}";
      rustTarget =
        {
          "x86_64-linux" = "x86_64-unknown-linux-gnu";
          "aarch64-darwin" = "aarch64-apple-darwin";
        }
        .${pkgs.stdenv.system};
      rustSrcUrl = "https://static.rust-lang.org/dist/rust-${rustToolchain}-${rustTarget}.tar.xz";
      rustSrcSha256 =
        {
          "https://static.rust-lang.org/dist/rust-1.75.0-aarch64-apple-darwin.tar.xz" =
            "sha256-aQmjlCw6uW0IBNuuC2or5CAa/3MJEcM9XD3HTtWgwNU=";
        }
        ."${rustSrcUrl}";

      rustBuild = pkgs.stdenv.mkDerivation {
        name = "rust-${rustToolchain}";
        src = pkgs.fetchurl {
          url = rustSrcUrl;
          sha256 = rustSrcSha256;
        };
        nativeBuildInputs = [ pkgs.xz ];
        dontConfigure = true;
        dontBuild = true;
        installPhase = ''
          tar xf $src
          cd rust-${rustToolchain}-${rustTarget}
          ./install.sh \
            --prefix=$out \
            --components=rustc,rust-std-${rustTarget},cargo
        '';
        meta = {
          description = "Rust toolchain ${rustToolchain} (standalone binary installer)";
          homepage = "https://www.rust-lang.org/";
        };
      };
      tarball = pkgs.stdenv.mkDerivation {
        name = "${pname}-tarball";
        src = rustBuild;
        doCheck = false;
        dontFixup = true;
        nativeBuildInputs = with pkgs; [
          gnutar
        ];
        installPhase = ''
          runHook preInstall

          export HOME=$PWD
          export PATH=$src/bin:$PATH

          cargo new vendor --bin
          cd vendor
          cargo add ${packageRequest}
          cargo vendor vendor
          cd ..

          GZIP=-n tar --sort=name -C vendor -czf vendor.tgz .
          mv vendor.tgz $out

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
        cargo
        rustc
      ];

      installPhase = ''
        runHook preInstall

        export HOME=$PWD

        mkdir -p $out/bin vendor $HOME/.cargo
        tar -C vendor -xzf $src

        cat > $HOME/.cargo/config.toml <<EOF
          [source.crates-io]
          replace-with = "vendored-sources"
          [source.vendored-sources]
          directory = "$HOME/vendor/vendor"
        EOF

        cd vendor/vendor/${name}
        rm -f Cargo.lock
        cargo build --release

        mv ./target/release/${name} $out/bin/${name}

        runHook postInstall
      '';
      postFixup = ''
        # Patch every shebang inside $out to use store path node
        patchShebangs $out
      '';
    };
}
