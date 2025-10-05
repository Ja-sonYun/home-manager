{
  pkgs,
  configDir,
  ...
}:
{
  home.packages = with pkgs; [
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
    moar
    zstd
    caddy
    gnupg
    flock
    argc

    # productivity
    glow # markdown previewer in terminal
    nix-search-cli
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

    # My nvim config
    nvim-pkg
    say
    plot

    nix-tree
    nix-index
    nix-output-monitor

    devenv
    awscli-local
  ];

  home.sessionVariables = {
    EDITOR = "${pkgs.nvim-pkg}/bin/nvim";
    # PAGER = "${pkgs.moar}/bin/moar";
    FLAKE_TEMPLATES_DIR = "${configDir}/templates";
  };

  home.shellAliases = {
    vi = "nvim";
    vim = "nvim";
    cat = "bat";
    gsed = "sed";
    watch = "hwatch";
  };
}
