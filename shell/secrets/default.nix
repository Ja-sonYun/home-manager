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
    openai-api-pkey = {
      file = "${agenix-secrets}/openai-api-pkey.age";
    };
    context7-api-key = {
      file = "${agenix-secrets}/context7-api-key.age";
    };
    slack = {
      file = "${agenix-secrets}/slack.age";
    };
  };

  home.sessionVariables = {
    GITHUB_PAT = "$(cat ${config.age.secrets.github-token.path} 2>/dev/null || echo '')";
    OPENAI_API_KEY = "$(cat ${config.age.secrets.openai-api-key.path} 2>/dev/null || echo '')";
    OPENAI_API_PKEY = "$(cat ${config.age.secrets.openai-api-pkey.path} 2>/dev/null || echo '')";
  };
}
