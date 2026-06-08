# modules/home/aider/model-settings.nix

{
  config,
  pkgs,
  lib,
  ...
}:
let
  modelSettingsText = ''
    # ~/.aider.model.settings.yml

    # === Основная модель ===
    - name: openrouter/deepseek/deepseek-v4-pro
      edit_format: diff
      use_repo_map: true
      reminder: sys
      examples_as_sys_msg: true
      caches_by_default: true
      extra_params:
        max_tokens: 8192
        reasoning_effort: high

    # === Запасная модель: Kimi 2.6 — reasoning ОТКЛЮЧЕН ===
    - name: openrouter/moonshotai/kimi-k2.6
      edit_format: diff
      use_repo_map: true
      reminder: sys
      caches_by_default: true
      extra_params:
        max_tokens: 8192
        reasoning_effort: disabled


    # === Weak модель: Qwen 2.5 7B для коммитов ===
    - name: openrouter/qwen/qwen-2.5-7b-instruct
      edit_format: diff
      use_repo_map: false
      caches_by_default: true
      extra_params:
        max_tokens: 4096
  '';

  configFileStore = pkgs.writeText "aider.model.settings.yml" modelSettingsText;

  configDir      = "${config.home.homeDirectory}/.config/aider";
  configFileReal = "${configDir}/aider.model.settings.yml";
in
{
  # Один раз создаём настоящий файл (вне store), если его ещё нет.
  home.activation.createModelSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${configDir}
    if [ ! -f ${configFileReal} ]; then
      cp ${configFileStore} ${configFileReal}
    fi
  '';

  # Символическая ссылка ~/.aider.model.settings.yml -> ~/.config/aider/aider.model.settings.yml
  home.file.".aider.model.settings.yml" = {
    source = config.lib.file.mkOutOfStoreSymlink configFileReal;
    force  = true;
  };
}
