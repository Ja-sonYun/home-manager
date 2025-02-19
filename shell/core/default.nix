{ pkgs, ... }:
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
    gawk

    # productivity
    glow # markdown previewer in terminal
    nix-search-cli
    viu

    httpie
    wget

    aider-chat
  ];

  home.sessionVariables = {
    PAGER = "${pkgs.moar}/bin/moar";
  };

  home.shellAliases = {
    gsed = "sed";
  };
}
