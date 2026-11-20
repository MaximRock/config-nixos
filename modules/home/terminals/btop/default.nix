{
  config,
  lib,
  ...
}:

with lib;

let
  cfg = config.modules.home.terminals.btop;
in
{
  options.modules.home.terminals.btop = {
    enable = mkEnableOption "btop system monitor";
  };

  config = mkIf cfg.enable {
    # Конфиг дашборда-монитора на столе 3 (niri). Тема gruvbox_dark — в тон wezterm.
    # theme_background = false + прозрачность wezterm дают эффект матового стекла.
    programs.btop = {
      enable = true;
      settings = {
        color_theme = "gruvbox_dark";
        theme_background = false;
        truecolor = true;
        rounded_corners = true;
        graph_symbol = "braille";

        # Без списка процессов — только метрики, как в старом дашборде.
        shown_boxes = "cpu mem net";
        update_ms = 2000;

        # Часы уже есть в баре Noctalia.
        clock_format = "";
        show_uptime = true;

        check_temp = true;
        cpu_sensor = "Auto";
        temp_scale = "celsius";
        show_cpu_freq = true;
        show_gpu_info = "Auto";
        cpu_graph_upper = "total";
        cpu_graph_lower = "total";

        mem_graphs = true;
        show_disks = true;
        show_io_stat = true;
        io_mode = false;
        disks_filter = "/";
        show_swap = false;

        net_iface = "enp7s0";
        net_auto = true;
        base_10_bitrate = true;

        vim_keys = true;

        # Конфиг из Nix — только для чтения.
        save_config_on_exit = false;
      };
    };
  };
}
