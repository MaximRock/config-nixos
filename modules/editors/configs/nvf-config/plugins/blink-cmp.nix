{ ... }:

{
  enable = true;
  friendly-snippets.enable = true;

  setupOpts = {
    fuzzy.implementation = "rust";
    keymap.preset = "cmdline";
    sources.default = [
      "lsp"
      "path"
      "snippets"
      "buffer"
    ];

    cmdline = {
      sources = [
        "path"
        "cmdline"
      ];
      completion = {
        menu.auto_show = false;
        ghost_text = {
          enabled = true;
        };
      };
      keymap.preset = "inherit";
    };
  };
}
