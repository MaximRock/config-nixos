{ pkgs, ... }:

let
  varGrammars = import ../nvf-var.nix { inherit pkgs; };
  grammarsList = varGrammars.treesitterGrammars;
in

{
  enable = true;
  addDefaultGrammars = true;
  grammars = builtins.map (name: 
    pkgs.vimPlugins.nvim-treesitter.builtGrammars.${name}
  ) grammarsList;

  context = {
    enable = true;
    setupOpts = {
      line_numbers = true;
      max_lines = 5;
    };
  };
  indent.enable = false;
  highlight.enable = true;
  #incrementalSelection.enable = true;
}
