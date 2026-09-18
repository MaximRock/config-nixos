# home/common/ai-agents.nix

{ ... }:

let
  modulesHome = toString ../../modules/home;
in

{
  imports = [
    "${modulesHome}/ai-agents/aider"
    "${modulesHome}/ai-agents/koda"
    "${modulesHome}/ai-agents/dyad"
    "${modulesHome}/ai-agents/opencode"
    "${modulesHome}/ai-agents/rime-mcp"
    "${modulesHome}/ai-agents/graft"
    "${modulesHome}/ai-agents/dsh"
    "${modulesHome}/ai-agents/updates"
    "${modulesHome}/ai-agents/ponytail"
    "${modulesHome}/ai-agents/comfyui"
    "${modulesHome}/ai-agents/nix-repo-navigator"
  ];
  modules.home = {
    aider.enable = false;
    koda.enable = false;
    dyad.enable = true;
    opencode.enable = true;
    rime-mcp.enable = true;
    graft.enable = true;
    dsh.enable = true;
    npmUpdate.enable = true;
    ponytail.enable = true;
    comfyui.enable = false;
    nix-repo-navigator.enable = true;
  };
}
