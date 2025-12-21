let
  pkgs = import <nixpkgs> { };
  system = builtins.currentSystem;
  hostname = "__HOSTNAME__";
  hashfile = builtins.fromJSON (builtins.readFile __ROOT_DIR__/pkgs/hashfile.json);
  customLibs = import __ROOT_DIR__/libs { inherit pkgs system; };
  finalPkgs = pkgs // {
    hashfile = hashfile."${hostname}";
    lib = pkgs.lib // customLibs;
  };
in
pkgs.callPackage __FILE__ { pkgs = finalPkgs; }
