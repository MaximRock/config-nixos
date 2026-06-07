# modules/home/aider/default.nix

# {
#   config,
#   pkgs,
#   username,
#   unstable,
#   ...
# }:
# let
#   secretName = "OPENROUTER_API_KEY";
#   secretPath = "/run/secrets/${secretName}";
# in

# {

#   #1. Безопасная обёртка с подстановкой ключа
#   home.packages = [
#     (pkgs.writeShellScriptBin "aider" ''
#       if [ -f "${secretPath}" ]; then
#         export OPENROUTER_API_KEY=$(cat "${secretPath}")
#         export OPENAI_API_KEY="$OPENROUTER_API_KEY"  # aider иногда проверяет и эту переменную
#       else
#         echo "⚠️  Secret ${secretPath} not found. Run 'sudo nixos-rebuild switch'." >&2
#       fi
#       exec ${pkgs.aider-chat}/bin/aider "$@"
#     '')
#   ];

#   #2. Основной конфиг aider
#   home.file.".aider.conf.yml".text = ''
#     openai-api-base: https://openrouter.ai/api/v1
#     model: openrouter/moonshotai/kimi-k2.6
#     editor-model: openrouter/moonshotai/kimi-k2.6
#     weak-model: openrouter/qwen/qwen-2.5-7b-instruct
#     commit-model: openrouter/qwen/qwen-2.5-7b-instruct
#     summarize-model: openrouter/qwen/qwen-2.5-7b-instruct

#     model-settings-file: /home/${username}/.aider.model.settings.yml

#     # Язык общения
#     detect-language: true
#     chat-language: Russian

#     show-model-warnings: false

#     # Формат правок (kimi-k2.6:free лучше работает с whole, чем с diff)
#     edit-format: whole

#     stream: true
#     auto-commits: true
#     dark-mode: true
#     map-tokens: 4096
#     auto-lint: false
#     auto-test: false
#     max-chat-history-tokens: 16384

#     # Не спрашивать подтверждение на коммиты
#     dirty-commits: true
#   '';

#   # 3. Настройки для обеих моделей (отключение рассуждений/think-блоков)
#   home.file.".aider.model.settings.yml".text = ''
#     - name: "openrouter/moonshotai/kimi-k2.6"
#       edit_format: whole
#       extra_params:
#         max_tokens: 8192
#         temperature: 0.3
#         top_p: 0.95
#         enable_thinking: false
#         thinking-tokens: 0
#     - name: "openrouter/qwen/qwen-2.5-7b-instruct"
#       edit_format: whole
#       extra_params:
#         max_tokens: 4096
#         temperature: 0.2
#         top_p: 0.90
#         enable_thinking: false
#   '';
# }

{
  config,
  pkgs,
  username,
  ...
}:
let
  # Имя секрета должно совпадать с тем, что в sops.secrets.*
  # Если выбрали OPENROUTER_API_KEY — оставьте так
  # Если openrouteservice_api_key — замените ниже
  secretName = "OPENROUTER_API_KEY";
  secretPath = "/run/secrets/${secretName}";
in
{
  # 1. Безопасная обёртка: подставляет ключ ТОЛЬКО в процесс aider
  home.packages = [
    (pkgs.writeShellScriptBin "aider" ''
      if [ -f "${secretPath}" ]; then
        export OPENROUTER_API_KEY=$(cat "${secretPath}")
        export AIDER_OPENROUTER_API_KEY="$OPENROUTER_API_KEY"
      else
        echo "⚠️  Secret ${secretPath} not found. Run 'sudo nixos-rebuild switch' and relogin." >&2
      fi
      exec ${pkgs.aider-chat}/bin/aider "$@"
    '')
  ];

  #   #2. Основной конфиг aider
  home.file.".aider.conf.yml".text = ''
    openai-api-base: https://openrouter.ai/api/v1
    model: openrouter/moonshotai/kimi-k2.6
    editor-model: openrouter/moonshotai/kimi-k2.6
    weak-model: openrouter/qwen/qwen-2.5-7b-instruct

    model-settings-file: /home/${username}/.aider.model.settings.yml

    # Язык общения
    # detect-language: true
    chat-language: Russian

    show-model-warnings: false

    # Формат правок (kimi-k2.6:free лучше работает с whole, чем с diff)
    edit-format: whole

    stream: true
    auto-commits: true
    dark-mode: true
    map-tokens: 4096
    auto-lint: false
    auto-test: false
    max-chat-history-tokens: 16384

    # Не спрашивать подтверждение на коммиты
    dirty-commits: true
  '';

  # 3. Настройки для обеих моделей (отключение рассуждений/think-блоков)
  home.file.".aider.model.settings.yml".text = ''
    - name: "openrouter/moonshotai/kimi-k2.6"
      edit_format: whole
      extra_params:
        max_tokens: 8192
        temperature: 0.3
        top_p: 0.95
        enable_thinking: false
        thinking-tokens: 0
    - name: "openrouter/qwen/qwen-2.5-7b-instruct"
      edit_format: whole
      extra_params:
        max_tokens: 4096
        temperature: 0.2
        top_p: 0.90
        enable_thinking: false
  '';

  # 2. Глобальный конфиг Aider (без ключа!)
  # home.file.".aider.conf.yml".text = ''
  #     # OpenRouter endpoint
  #     openai-api-base: https://openrouter.ai/api/v1
  #     # Ключ подставляется через обёртку, здесь не указываем
  #     # openai-api-key: local  # ← удаляем или комментируем

  #     # Модель через OpenRouter
  #     model: openrouter/deepseek/deepseek-v3.2

  #     # ✅ Язык общения
  #     # detect-language: true
  #     chat-language: Russian

  #     # Параметры
  #     show-model-warnings: false
  #     edit-format: diff
  #     stream: true
  #     auto-commits: true
  #     dark-mode: true
  #     map-tokens: 2048
  #     auto-lint: false
  #     auto-test: false
  #     max-chat-history-tokens: 8192
  # '';

  # # 3. Настройки модели (опционально)
  # home.file.".aider.model.settings.yml".text = ''
  #   - name: "openrouter/deepseek/deepseek-v3.2"
  #     edit_format: diff
  #     extra_params:
  #       max_tokens: 32768
  #       temperature: 0.2
  #       top_p: 0.95
  #   use_temperature: 0.2
  # '';

  # 4. (Опционально) Алиас для удобства
  # programs.zsh.initExtra = ''
  #   alias aider='aider'
  # '';
}
