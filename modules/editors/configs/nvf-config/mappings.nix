{ ... }:

{
  mappKeys = [
    {
      mode = "n";
      key = "<leader>e";
      action = ":Neotree toggle<CR>";
      desc = "Toggle Neo-tree";
    }
    {
      mode = "n";
      key = "<leader>o";
      action = ":Neotree focus<CR>";
      desc = "Focus Neo-tree";
    }
    {
      mode = "n";
      key = "<Tab>";
      action = ''
        function()
          vim.cmd("wincmd p")
        end
      '';
      lua = true;
      desc = "Switch to previous window";
    }
    {
      mode = "n";
      key = "<leader>rn";
      action = ":IncRename ";
      desc = "Used IncRename";
    }
  ];
}
