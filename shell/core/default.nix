{
  pkgs,
  configDir,
  ...
}:
{
  home.packages = with pkgs; [
    git-wrapped

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processer https://github.com/mikefarah/yq
    dasel

    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing

    # misc
    file
    which
    tree
    gnused
    gnutar
    gawk
    moor
    zstd
    caddy
    gnupg
    flock
    argc

    # productivity
    glow # markdown previewer in terminal
    viu

    lazygit
    lazysql

    comma

    httpie
    wget

    hwatch

    mermaid-cli

    entr
    fd
    dua
    glance

    cookiecutter

    # My vim config
    vim-dev
    say
    plot

    nh
    nix-output-monitor

    devenv
    awscli
    awscli-local
    cloudflared
  ];

  home.sessionVariables = {
    EDITOR = "${pkgs.vim-dev}/bin/vim";
    # PAGER = "${pkgs.moor}/bin/moor";
    FLAKE_TEMPLATES_DIR = "${configDir}/templates";
  };

  home.shellAliases = {
    vi = "vim";
    cat = "bat";
    gsed = "sed";
    watch = "hwatch";
  };
}
