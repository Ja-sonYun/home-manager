{ pkgs
, ...
}:
{
  home.packages = with pkgs; [
    colima
    docker-client
    docker-compose
    docker-buildx
    docker-credential-helpers
  ];
}
