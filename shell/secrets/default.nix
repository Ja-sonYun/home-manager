{ config
, pkgs
, agenix-secrets
, agenix
, ...
}:
let
  bundleHash = builtins.substring 0 8 (builtins.hashFile "sha256" "${agenix-secrets}/encrypted/claude-bundle.age");
in
{
  home.packages = [ agenix.packages.${pkgs.system}.default ];

  age.secrets = {
    github-token = {
      file = "${agenix-secrets}/encrypted/github-token.age";
    };
    openai-api-key = {
      file = "${agenix-secrets}/encrypted/openai-api-key.age";
    };
    openai-api-pkey = {
      file = "${agenix-secrets}/encrypted/openai-api-pkey.age";
    };
    context7-api-key = {
      file = "${agenix-secrets}/encrypted/context7-api-key.age";
    };
    deepseek-api-key = {
      file = "${agenix-secrets}/encrypted/deepseek-api-key.age";
    };
    claude-bundle = {
      file = "${agenix-secrets}/encrypted/claude-bundle.age";
      path = "${config.home.homeDirectory}/.claude/nix/.secret.${bundleHash}";
    };
  };

  home.sessionVariables = {
    GITHUB_PAT = "$(cat ${config.age.secrets.github-token.path} 2>/dev/null || echo '')";
    OPENAI_API_KEY = "$(cat ${config.age.secrets.openai-api-key.path} 2>/dev/null || echo '')";
    OPENAI_API_PKEY = "$(cat ${config.age.secrets.openai-api-pkey.path} 2>/dev/null || echo '')";
    DEEPSEEK_API_KEY = "$(cat ${config.age.secrets.deepseek-api-key.path} 2>/dev/null || echo '')";
  };
}
