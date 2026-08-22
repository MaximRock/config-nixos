# AI-MODULE-GUIDE.md — Как писать модули для `.dotfiles`

## Структура модулей

```
modules/
├── home/           # home-manager-модули (импортируются из home/common/*.nix)
└── nixos/          # NixOS-модули (импортируются из modules/nixos/default.nix)
```

Все модули — это `{ ... }:` лямбды с атрибут-сетом.  
Большинство следуют паттерну:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.<category>.<name>;
in

{
  options.modules.home.<category>.<name> = {
    enable = mkEnableOption "<description>";
  };

  config = mkIf cfg.enable {
    # ...
  };
}
```

---

## 1. Simple — enable + home.packages

Тривиальный модуль: включает опцию и устанавливает пакет.

**Файлы:** deadbeef, strawberry, fuzzel, swaybg, swayidle, wlogout, flameshot, flameshot

**Шаблон:**

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.<category>.<name>;
in

{
  options.modules.home.<category>.<name> = {
    enable = mkEnableOption "<name>";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.<name> ];
  };
}
```

**Пример** — `modules/home/players/deadbeef/default.nix`:
```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.players.deadbeef;
in

{
  options.modules.home.players.deadbeef = {
    enable = mkEnableOption "DeadBeeF";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.deadbeef ];
  };
}
```

**Особенности:**
- Если у сервиса есть HM-модуль (`programs.*`, `services.*`), используй его вместо `home.packages`
- Вариант: `services.flameshot.enable = true;` вместо `home.packages`

---

## 2. Config-symlink — enable + mkOutOfStoreSymlink

Модуль с файлом конфига, который должен быть доступен для редактирования в репозитории.  
Использует `variables.basePathFilesDir` + `mkOutOfStoreSymlink`.

**Файлы:** dsh, aider, niri (xdg.configFile), qtile (xdg.configFile), wezterm (xdg.configFile), git

**Шаблон:**

```nix
{ config, lib, pkgs, variables, ... }:

with lib;

let
  cfg = config.modules.home.<category>.<name>;
  base = "${variables.basePathFilesDir}/modules/home/<category>/<name>";
in

{
  options.modules.home.<category>.<name> = {
    enable = mkEnableOption "<name>";
  };

  config = mkIf cfg.enable {
    home.file."<path>".source =
      config.lib.file.mkOutOfStoreSymlink "${base}/<file>";

    # или через xdg.configFile для XDG-путей:
    xdg.configFile."<app>/<file>".source =
      config.lib.file.mkOutOfStoreSymlink "${base}/<file>";
  };
}
```

**Пример** — `modules/home/ai-agents/dsh/default.nix`:
```nix
{ config, lib, pkgs, variables, ... }:

with lib;

let
  cfg = config.modules.home.dsh;
  base = "${variables.basePathFilesDir}/modules/home/ai-agents/dsh";
in

{
  options.modules.home.dsh = {
    enable = mkEnableOption "DeepSeek Harness (DSH)";
  };

  config = mkIf cfg.enable {
    home.file.".dsh/settings.yaml".source =
      config.lib.file.mkOutOfStoreSymlink "${base}/settings.yaml";
  };
}
```

**Важно:**
- `home.file` ищет относительно `$HOME` — указать полный путь от `$HOME` (например `".dsh/settings.yaml"`)
- `xdg.configFile` ищет относительно `$XDG_CONFIG_HOME` (обычно `~/.config`)
- Переменная `base` должна быть строкой `"${variables.basePathFilesDir}/modules/home/..."` — это путь к репозиторию

---

## 3. Activation — enable + home.activation

Модуль с `home.activation` для выполнения скриптов при переключении HM.  
Используется для npm install, pip install, настройки окружения.

**Файлы:** koda, graft, opencode (sessionPath)

**Шаблон:**

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.home.<category>.<name>;
in

{
  options.modules.home.<category>.<name> = {
    enable = mkEnableOption "<name>";
  };

  config = mkIf cfg.enable {
    home.activation.install<Name> = ''
      export NPM_CONFIG_PREFIX="$HOME/.npm-global"
      export PATH="${pkgs.nodejs_22}/bin:$HOME/.npm-global/bin:$PATH"

      npm install -g <package>
    '';

    home.sessionPath = [ "$HOME/.npm-global/bin" ];
  };
}
```

**Особенности:**
- Всегда экспортируй `NPM_CONFIG_PREFIX`, `PATH` — HM не наследует окружение пользователя
- Разные `home.activation.*` не имеют гарантированного порядка выполнения
- Для Node-модулей всегда используй `pkgs.nodejs_22` (Node 22 LTS)

---

## 4. Submodule — организационный импорт

Модуль, который только импортирует дочерние подмодули. Не имеет `options`/`config`.

**Файлы:** wayland/default.nix, qtile/default.nix, firefox/default.nix, editors/default.nix, nvf/default.nix

**Шаблон:**

```nix
{ ... }:

{
  imports = [
    ./<submodule1>
    ./<submodule2>
    ./<submodule3>
  ];
}
```

**Пример** — `modules/home/browsers/firefox/default.nix`:
```nix
{ ... }:

{
  imports = [
    ./base.nix
    ./nighttab.nix
    ./chrome-css.nix
  ];
}
```

**Важные детали:**
- Пути в imports — относительные, без кавычек `./name` или `./name/default.nix`
- Подмодули могут быть директориями (грузится `default.nix`) или явными `.nix` файлами
- Submodule не должен иметь `options` — опции определяют его дочерние модули

---

## 5. Complex — расширенные опции + кастомная логика

Модули с несколькими опциями (`mkOption`), импортом дополнительных библиотек, сложной конфигурацией.

**Файлы:** waybar (colors), swaylock (colors), mako (colors), yazi (themeName + colors), wezterm (themeName), vscode, vscodium, niri (theme + submodule imports + multi-file config)

**Ключевые черты:**

| Модуль | Сложность |
|--------|-----------|
| waybar | Colors + programs.waybar.settings + style |
| swaylock | Colors + services.swaylock |
| mako | Colors + services.mako |
| yazi | themeName + colors + programs.yazi.flavors + keymap |
| wezterm | themeName + terminalLib.mkTerminalOptions + programs.wezterm |
| vscode/vscodium | mkCodeOptions + mkCodeConfig + common-settings + extensions |
| niri | theme + submodule imports + xdg.configFile x3 |
| dunst | import ./settings.nix с colors |

**Паттерн с импортом общей библиотеки опций:**

```nix
let
  terminalLib = import ../lib.nix { inherit pkgs lib; };
in

{
  options.modules.home.<category>.<name> =
    terminalLib.mkTerminalOptions "<Name>" pkgs.<default-package> // {
      themeName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Override theme name";
      };
    };
}
```

**Паттерн с colors:**

```nix
options.modules.home.<category>.<name> = {
  enable = mkEnableOption "<name>";
  colors = mkOption {
    type = types.nullOr (types.attrsOf types.str);
    default = null;
    description = "Color palette";
  };
};
```

---

## Карта всех модулей (модуль → тип)

| Путь | Тип | Описание |
|------|-----|----------|
| `ai-agents/aider` | Config-symlink + Activation | wrapper script, symlinks конфигов |
| `ai-agents/dsh` | Config-symlink | symlink settings.yaml |
| `ai-agents/graft` | Activation | npm install -g |
| `ai-agents/koda` | Activation | npm install -g |
| `ai-agents/nixos-helper` | — | nixpkgs package (buildPythonApplication) |
| `ai-agents/opencode` | Activation + Config-symlink | config + project + agents + skills dirs |
| `ai-agents/open-design` | Simple | services.open-design.enable |
| `ai-agents/rime-mcp` | Simple | home.packages = [ pkgs.rime ] |
| `browsers/firefox/default.nix` | Submodule | импорты ./base, ./nighttab, ./chrome-css |
| `browsers/firefox/base.nix` | Complex | programs.firefox + policies |
| `desktop/dunst` | Complex | import ./settings.nix + services.dunst |
| `desktop/flameshot` | Simple | services.flameshot.enable |
| `desktop/gtk` | Simple | gtk.enable + theme/icon theme |
| `desktop/picom` | Simple | services.picom |
| `desktop/rofi` | Simple | programs.rofi |
| `desktop/wayland/default.nix` | Submodule | импорты subdirs |
| `desktop/wayland/fuzzel` | Simple | home.packages |
| `desktop/wayland/mako` | Complex | services.mako + colors |
| `desktop/wayland/swaybg` | Simple | home.packages |
| `desktop/wayland/swayidle` | Simple | home.packages |
| `desktop/wayland/swaylock` | Complex | services.swaylock + colors |
| `desktop/wayland/waybar` | Complex | programs.waybar + colors + style |
| `desktop/wayland/wlogout` | Simple | home.packages |
| `editors/default.nix` | Submodule | импорты nvf, vscodium, vscode |
| `editors/nvf` | Submodule + Complex | mkOption extraPlugins + imports |
| `editors/vscode` | Complex | mkCodeOptions + common-settings |
| `editors/vscodium` | Complex | mkCodeOptions + common-settings + workspace-nix |
| `editors/lib.nix` | — | библиотека mkCodeOptions / mkCodeConfig |
| `editors/configs/nvf-config` | Complex | 15+ plugin-файлов, lsp, mappings |
| `git` | Config-symlink | programs.git + settings |
| `players/deadbeef` | Simple | home.packages |
| `players/strawberry` | Simple | home.packages |
| `shell/zsh` | Simple + Config-symlink | programs.zsh + initContent |
| `terminals/fastfetch` | Complex | кастомный конфиг с logo и colors |
| `terminals/herdr` | Simple | home.packages |
| `terminals/lib.nix` | — | библиотека mkTerminalOptions |
| `terminals/wezterm` | Complex | programs.wezterm + mkTerminalOptions + themeName + keys.lua |
| `terminals/yazi` | Complex | programs.yazi + flavors + themeName + colors + keymap |
| `wm/niri` | Complex | imports lib/niri/theme + wayland + xdg.configFile x3 + theme |
| `wm/qtile/default.nix` | Submodule | imports ./power-menu ./qtile-help |
| `wm/qtile/power-menu` | Simple | home.packages |
| `wm/qtile/qtile-help` | Simple | home.packages |

---

## Конвенции и правила

### Именование опций

Всегда `modules.home.<category>.<name>.enable`:
- ✅ `modules.home.players.deadbeef.enable`
- ✅ `modules.home.desktop.wayland.waybar.enable`
- ✅ `modules.home.wm.niri.enable`
- ❌ `services.deadbeef.enable`
- ❌ `programs.deadbeef.enable`

### Импорт модулей

Модули импортируются из файлов-агрегаторов в `home/common/`:
- `home/common/ai-agents.nix` → модули `ai-agents/*`
- `home/common/wm.nix` → модули `wm/*`
- `home/common/default.nix` → редакторы, оболочка, git, десктоп

Паттерн импорта:
```nix
# home/common/xxx.nix
{ ... }:

let
  modulesHome = toString ../../modules/home;
in

{
  imports = [
    "${modulesHome}/<category>/<name>"
  ];

  modules.home.<category>.<name>.enable = true;
}
```

### Общие библиотеки

- `modules/home/editors/lib.nix` — `mkCodeOptions`, `mkCodeConfig`
- `modules/home/terminals/lib.nix` — `mkTerminalOptions`
- Будущая: `lib/module.nix` — `mkSimpleModule`, `mkConfigModule`, `mkActivationModule`

### Переменные в specialArgs

Через `lib/default.nix` пробрасываются в specialArgs:
- `variables` — `basePathFilesDir` (путь к репозиторию)
- `appColors` — темы приложений
- `appThemeNames` — названия тем
- `inputs` — flake-инпуты (nvf, wezterm, llm-agents, herdr)
- `unstable` — nixpkgs-unstable

### mkOutOfStoreSymlink vs обычный source

- `source = config.lib.file.mkOutOfStoreSymlink "${base}/<file>"` — **симлинк на файл в репозитории**, можно редактировать
- `source = ./<file>` — копируется в /nix/store (read-only)

Всегда используй `mkOutOfStoreSymlink` для конфигов, которые пользователь может редактировать.

### with lib;

- Используй `with lib;` после заголовка функции — это даёт прямой доступ к `mkEnableOption`, `mkIf`, `mkOption`, `types.*`
- Можно не использовать, если вызываешь `lib.mkEnableOption` — но конвенция в этом репо — `with lib;`

---

## Быстрый старт: создание нового модуля

```bash
# 1. Создай директорию
mkdir -p modules/home/<category>/<name>

# 2. Напиши default.nix по одному из шаблонов выше

# 3. Подключи в home/common/*.nix:
#    - добавь "${modulesHome}/<category>/<name>" в imports
#    - добавь modules.home.<category>.<name>.enable = true;
```