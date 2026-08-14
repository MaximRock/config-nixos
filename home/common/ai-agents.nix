# home/common/ai-agents.nix

{ ... }:

let
  modulesHome = toString ../../modules/home;
in 

{
  imports = [
    "${modulesHome}/ai-agents/aider"
    "${modulesHome}/ai-agents/koda"
    "${modulesHome}/ai-agents/opencode"
    "${modulesHome}/ai-agents/rime-mcp"
    "${modulesHome}/ai-agents/open-design"
    "${modulesHome}/ai-agents/graft"
  ];
  modules.home = {
    aider.enable = true;
    koda.enable = true;
    opencode.enable = true;
    rime-mcp.enable = true;
    open-design.enable = true;
    graft.enable = true;
  };
}
