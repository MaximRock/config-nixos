# modules/home/aider/model-metadata.nix

{
  config,
  pkgs,
  lib,
  ...
}:
let
  modelMetadataText = ''
    {
      "openrouter/deepseek/deepseek-v4-pro": {
        "max_tokens": 8192,
        "max_input_tokens": 1000000,
        "max_output_tokens": 8192,
        "input_cost_per_token": 4.35e-07,
        "output_cost_per_token": 8.7e-07,
        "mode": "chat"
      },
      "openrouter/moonshotai/kimi-k2.6": {
        "max_tokens": 8192,
        "max_input_tokens": 256000,
        "max_output_tokens": 8192,
        "input_cost_per_token": 1.0e-06,
        "output_cost_per_token": 2.0e-06,
        "mode": "chat"
      },
      "openrouter/qwen/qwen-2.5-7b-instruct": {
        "max_tokens": 4096,
        "max_input_tokens": 128000,
        "max_output_tokens": 4096,
        "input_cost_per_token": 2.0e-08,
        "output_cost_per_token": 5.0e-08,
        "mode": "chat"
      }
    }
  '';

  configFileStore = pkgs.writeText "aider.model.metadata.yml" modelMetadataText;

  configDir      = "${config.home.homeDirectory}/.config/aider";
  configFileReal = "${configDir}/aider.model.metadata.yml";
in
{
  # Один раз создаём настоящий файл (вне store), если его ещё нет.
  home.activation.createModelMetadata = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${configDir}
    if [ ! -f ${configFileReal} ]; then
      cp ${configFileStore} ${configFileReal}
    fi
  '';

  # Символическая ссылка ~/.aider.model.metadata.yml -> ~/.config/aider/aider.model.metadata.yml
  home.file.".aider.model.metadata.yml" = {
    source = config.lib.file.mkOutOfStoreSymlink configFileReal;
    force  = true;
  };
}
