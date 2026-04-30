{ ... }:

{
  setupNeoTree = {
    close_if_last_window = true;
    enable_git_status = true;
    # enable_diagnostics = true;
    diagnostics = {
      enable = true;
      severity.sort = true;
    };
    sources = [
      "filesystem"
      "buffers"
      "git_status"
    ];
    source_selector = {
      winbar = true;
      statusline = false;
      sources = [
        {
          source = "filesystem";
          display_name = " Files";
        }
        {
          source = "buffers";
          display_name = " Buffers";
        }
        {
          source = "git_status";
          display_name = " Git";
        }
      ];
    };
    filesystem = {
      filtered_items = {
        visible = true;
        hide_dotfiles = false;
        hide_gitignored = false;
      };
      follow_current_file = {
        enabled = true;
      };
    };
    buffers = {
      follow_current_file = {
        enabled = true;
      };
    };
    git_status = {
      window = {
        position = "float";
      };
    };
    window = {
      position = "left";
      width = 35;
      mappings = {
        "<2-LeftMouse>" = "open";
        "<C-j>" = "next_source";
        "<C-k>" = "prev_source";
      };
    };
  };
}
