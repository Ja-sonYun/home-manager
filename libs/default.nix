{ pkgs, system }:
{
  npm = import ./npm { inherit pkgs system; };
  pip = import ./pip { inherit pkgs system; };
  cargo = import ./cargo { inherit pkgs system; };
}
