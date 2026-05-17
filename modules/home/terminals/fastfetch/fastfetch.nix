{ config, pkgs, lib, ... }:

let
  # 🖼️ Путь к вашему логотипу относительно ЭТОГО .nix файла
  # Положите logo.png в ту же папку, где лежит этот файл, или измените путь
  logoFile = ./logo3.png;

  # 📝 Конфигурация fastfetch в формате Nix
  fastfetchConfig = {
    logo = {
      type = "kitty";  # WezTerm, Kitty, Alacritty поддерживают этот протокол
      source = "$HOME/.config/fastfetch/logo.png";
      
      # Размер в ячейках терминала (подберите под себя)
      width = 30;
      height = 15;
      
      # Отступы для ровного выравнивания с текстом
      padding = {
        top = 1;
        bottom = 1;
        left = 2;
        right = 4;
      };
    };

    # 🎨 Цвета интерфейса (Catppuccin Mocha)
    color = {
      keys = "#b4befe";
      title = "#cba6f7";
      subtitle = "#9399b2";
      bar = "#585b70";
      separator = "#6c7086";
    };

    # 📊 Модули с иконками Nerd Fonts
    modules = [
      { type = "title"; keyColor = "#cba6f7"; }
      "separator"
      { type = "os"; key = " "; keyColor = "#89b4fa"; }
      { type = "host"; key = "󰍹 "; keyColor = "#cba6f7"; }
      { type = "kernel"; key = " "; keyColor = "#94e2d5"; }
      { type = "uptime"; key = "󰔟 "; keyColor = "#a6e3a1"; }
      # { type = "packages"; key = "󰏖 "; keyColor = "#f9e2af"; }
      { type = "shell"; key = " "; keyColor = "#cba6f7"; }
      { type = "display"; key = "󰍹 "; keyColor = "#89b4fa"; }
      { type = "de"; key = " "; keyColor = "#94e2d5"; }
      # { type = "wm"; key = " "; keyColor = "#cba6f7"; }
      { type = "theme"; key = " "; keyColor = "#f9e2af"; }
      { type = "terminal"; key = " "; keyColor = "#a6e3a1"; }
      { type = "cpu"; key = " "; keyColor = "#f38ba8"; }
      { type = "gpu"; key = "󰢮 "; keyColor = "#a6e3a1"; }
      { type = "memory"; key = " "; keyColor = "#89b4fa"; }
      { type = "disk"; key = "󰋊 "; keyColor = "#fab387"; }
      "colors"
    ];
  };

in
{

  # home.packages = with pkgs; [ fastfetch ];

  # 2️⃣ Отключаем встроенный модуль HM (чтобы не конфликтовал)
  programs.fastfetch.enable = false;

  # 3️⃣ Копируем изображение из репозитория в ~/.config/fastfetch/logo.png
  xdg.configFile."fastfetch/logo.png".source = logoFile;

  # 4️⃣ Генерируем и размещаем конфиг
  xdg.configFile."fastfetch/config.jsonc".text = builtins.toJSON fastfetchConfig;
}