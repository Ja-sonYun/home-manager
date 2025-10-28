{ pkgs, ... }:
{
  home.shellAliases = {
    js = "jj st --no-pager";
    je = "jj edit";
    jd = "jj describe";
    jg = "jj git";
  };
  home.packages = with pkgs; [
    jjui
  ];

  programs.jujutsu = {
    package = pkgs.jujutsu;
    enable = true;

    ediff = false;

    settings = {
      user = {
        email = "killa30867@gmail.com";
        name = "Ja-sonYun";

      };
      ui = {
        default-command = [
          "log"
          "-n"
          "10"
          "--no-pager"
        ];
      };
    };
  };
}
