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
    "${modulesHome}/ai-agents/dsh"
    "${modulesHome}/ai-agents/updates"
    "${modulesHome}/ai-agents/ponytail"
  ];
  modules.home = {
    aider.enable = false;
    koda.enable = false;
    opencode.enable = true;
    rime-mcp.enable = true;
    open-design.enable = false;
    graft.enable = true;
    dsh.enable = true;
    npmUpdate.enable = true;
    ponytail.enable = true;
  };
}
