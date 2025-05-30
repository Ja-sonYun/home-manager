{
  pkgs,
  lib,
  userhome,
  ...
}:
let
  gem = "${pkgs.ruby_3_4}/bin/gem";
  gemHome = "${userhome}/.local/share/gem/ruby/3.4.0";
  icalPalHome = "${gemHome}/gems/icalPal-3.7.0";
  icalPalBin = "${gemHome}/bin/icalPal";
in
{
  home.sessionPath = [ "${icalPalHome}/bin" ];
  home.activation.installIcalPal = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e ${gemHome}/bin/icalPal ]; then
      export CC=/usr/bin/clang
      export SDKROOT=$(/usr/bin/xcrun --show-sdk-path)
      export PATH=${pkgs.gnumake}/bin:${pkgs.pkg-config}/bin:$PATH
      export PATH="/Library/Developer/CommandLineTools/usr/bin:$PATH"
      echo ${gem}
      ${gem} install --user-install bigdecimal -v 3.1.9 \
                  --platform arm64-darwin --no-document
      ${gem} install --user-install sqlite3    -v 2.6.0 \
                  --platform arm64-darwin --no-document
      ${gem} install --user-install timezone   -v 1.3.29 \
                  --platform arm64-darwin --no-document
      ${gem} install --user-install icalPal --no-document -v 3.7.0
      (echo "#!${pkgs.ruby_3_4}/bin/ruby"; cat ${icalPalBin}) > temp && mv temp ${icalPalBin} && chmod +x ${icalPalBin}
    else
      echo "icalPal is already installed at ${icalPalBin}"
    fi
  '';
}
