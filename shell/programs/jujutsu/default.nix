{ pkgs, ... }: {
  home.shellAliases = {
    js = "jj st --no-pager";
    je = "jj edit";
    jd = "jj describe";
    jg = "jj git";
  };

  # home.packages = with pkgs; [
  #   lazyjj
  # ];

  programs.jujutsu = {
    enable = true;

    ediff = true;

    settings = {
      user = {
        email = "killa30867@gmail.com";
        name = "Ja-sonYun";

      };
      ui = {
        default-command = [ "log" "-n" "10" "--no-pager" ];
      };
    };
  };
}
