# modules/home/editors/common-settings.nix

{ lib, cfg }:

{
  attrs = {
    # ── Explorer ──
    "explorer.confirmDelete" = false;
    "explorer.autoReveal" = false;
    "explorer.compactFolders" = false;

    # ── Files ──
    "files.autoSave" = "afterDelay";

    # ── Editor ──
    "editor.fontSize" = 17;
    "editor.minimap.enabled" = false;
    "editor.formatOnSave" = true;
    "editor.formatOnPaste" = true;
    "editor.formatOnType" = true;
    "editor.suggestOnTriggerCharacters" = true;
    "editor.inlineSuggest.enabled" = true;

    # ── Workbench ──
    "workbench.colorTheme" = "One Dark";
    "workbench.iconTheme" = "material-icon-theme";
    "workbench.editorAssociations"."*.0_x5" = "default";

    # ── Git ──
    "git.autoRepositoryDetection" = "subFolders";

    # ── One Dark Theme ──
    "oneDark.italic" = false;

  } // cfg.extraSettings;
}
