{
  pkgs,
  ...
}:
{
  programs.zshFunc = {
    meet-record = {
      description = "Record a meeting";
      command =
        let
          derivation = pkgs.stdenv.mkDerivation {
            name = "meet-record-venv";
            src = ./scripts;
            buildInputs = [ pkgs.python312 ];
            installPhase = ''
              python3 -m venv $out/venv
              source $out/venv/bin/activate
              pip install -r requirements.txt
              deactivate
            '';
          };
        in
        ''
          export PATH=${pkgs.ffmpeg}/bin:$PATH
          ${derivation}/venv/bin/python ${toString ./scripts/recorder.py}
        '';
    };
  };
}
