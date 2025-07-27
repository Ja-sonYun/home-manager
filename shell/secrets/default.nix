{
  config,
  pkgs,
  agenix-secrets,
  agenix,
  ...
}:
{
  home.packages = [ agenix.packages.${pkgs.system}.default ];

  age.secrets = {
    github-token = {
      file = "${agenix-secrets}/github-token.age";
    };
    openai-api-key = {
      file = "${agenix-secrets}/openai-api-key.age";
    };
  };

  home.sessionVariables = {
    GITHUB_PAT = "$(cat ${config.age.secrets.github-token.path} 2>/dev/null || echo '')";
    OPENAI_API_KEY = "$(cat ${config.age.secrets.openai-api-key.path} 2>/dev/null || echo '')";
  };
}
