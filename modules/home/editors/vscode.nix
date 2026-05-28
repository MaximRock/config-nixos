{
  pkgs,
  ...
}:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        dracula-theme.theme-dracula
        mskelton.one-dark-theme
        pkief.material-icon-theme
        ms-python.python
        ms-python.vscode-pylance
        charliermarsh.ruff
        jnoortheen.nix-ide
        continue.continue
      ];

      userSettings = {
        "explorer.confirmDelete" = false;
        "explorer.autoReveal" = false;
        "explorer.compactFolders" = false;
        "files.autoSave" = "afterDelay";
        "editor.fontSize" = 17;
        "editor.minimap.enabled" = false;
        "editor.formatOnSave" = true;
        "editor.formatOnPaste" = true;
        "editor.formatOnType" = true;
        "editor.suggestOnTriggerCharacters" = true;
        "workbench.colorTheme" = "One Dark";
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.editorAssociations"."*.0_x5" = "default";
        "git.autoRepositoryDetection" = "subFolders";
        "redhat.telemetry.enabled" = true;
        "oneDark.italic" = false;

        "continue.enableTabAutocomplete" = true;
        "continue.tabAutocompleteDelay" = 400;
        "continue.tabAutocompleteMultilineCompletions" = "always";
        "editor.inlineSuggest.enabled" = true;
      };
    };
  };
}
