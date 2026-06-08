# modules/home/aider/config.nix

{
  config,
  pkgs,
  lib,
  ...
}:
let
  commitPromptBody = builtins.readFile ./commit-prompt.txt;

  defaultConfigText = ''
    # ~/.aider.conf.yml
    model-settings-file: ~/.aider.model.settings.yml
    model-metadata-file: ~/.aider.model.metadata.json

    model: openrouter/deepseek/deepseek-v4-pro
    weak-model: openrouter/qwen/qwen-2.5-7b-instruct

    alias:
      - v4:openrouter/deepseek/deepseek-v4-pro
      - kimi:openrouter/moonshotai/kimi-k2.6
      - qwen:openrouter/qwen/qwen-2.5-7b-instruct

    # Основные настройки
    chat-language: Russian
    cache-prompts: true
    stream: true
    dark-mode: true
    pretty: true

    # Редактирование
    edit-format: diff
    auto-commits: true
    commit-prompt: |
      ${commitPromptBody}

    # Контекст
    map-refresh: auto
    map-tokens: 8192
    max-chat-history-tokens: 24000

    # NixOS
    #auto-lint: true
    #lint-cmd: "nix fmt"
    #auto-test: true
    #test-cmd: "nix flake check"

    # Служебное
    gitignore: true
    show-model-warnings: false
  '';

  configFileStore = pkgs.writeText "aider.conf.yml" defaultConfigText;

  configDir       = "${config.home.homeDirectory}/.config/aider";
  configFileReal  = "${configDir}/aider.conf.yml";
in
{
  home.activation.createAiderConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p ${configDir}
    if [ ! -f ${configFileReal} ]; then
      cp ${configFileStore} ${configFileReal}
    fi
  '';

  home.file.".aider.conf.yml" = {
    source = config.lib.file.mkOutOfStoreSymlink configFileReal;
    force  = true;
  };
}




# {
#   ...
# }:
# let
#   commitPromptBody = builtins.readFile ./commit-prompt.txt;

#   defaultConfigText = ''
#     # ~/.aider.conf.yml
#     model-settings-file: ~/.aider.model.settings.yml
#     model-metadata-file: ~/.aider.model.metadata.json

#     model: openrouter/deepseek/deepseek-v4-pro
#     weak-model: openrouter/qwen/qwen-2.5-7b-instruct

#     alias:
#       - v4:openrouter/deepseek/deepseek-v4-pro
#       - kimi:openrouter/moonshotai/kimi-k2.6
#       - qwen:openrouter/qwen/qwen-2.5-7b-instruct

#     # Основные настройки
#     chat-language: Russian
#     cache-prompts: true
#     stream: true
#     dark-mode: true
#     pretty: true

#     # Редактирование
#     edit-format: diff
#     auto-commits: true
#     commit-prompt: |
#       ${commitPromptBody}
#       # Напиши короткое сообщение коммита на русском языке, используя один из следующих префиксов: feat, fix, docs, style, refactor, test, chore, ci, perf.
#       #   Описания:
#       #   - feat - Новая функциональность
#       #   - fix  - Исправление бага
#       #   - docs - Только документация
#       #   - style - Форматирование, пробелы, линтеры
#       #   - refactor - Изменение структуры без изменения поведения
#       #   - test - Тесты
#       #   - chore - Обновление зависимостей, конфигов сборки
#       #   - ci - Изменения в CI/CD, скриптах сборки
#       #   - perf - Оптимизация производительности
#       #   Формат: <префикс>(scope): сообщение на русском языке, повелительное наклонение, не более 72 символов.
#       #   Пример: feat(qtile): обновить обои и настройки экрана

#     # Контекст
#     map-refresh: auto
#     map-tokens: 8192
#     max-chat-history-tokens: 24000

#     # NixOS
#     #auto-lint: true
#     #lint-cmd: "nix fmt"
#     #auto-test: true
#     #test-cmd: "nix flake check"

#     # Служебное
#     gitignore: true
#     show-model-warnings: false
#   '';

# in

# {
#   home.file.".aider.conf.yml".text = defaultConfigText;
# }
