{
  pkgs,
  lib,
  username,
  ...
}:

let
  vars = import ./var-editors.nix { inherit username; };
  sourceSettingsPath = "${vars.vscodeWorkspacePython}/${vars.vscodeSettingsFile}";

  vscodeSettingsContent = lib.generators.toJSON { } {
    "git.autoRepositoryDetection" = "subFolders";
    "breadcrumbs.enabled" = true;
    "python.languageServer" = "Pylance";
    "python.analysis.typeCheckingMode" = "off";
    "python.analysis.diagnosticMode" = "openFilesOnly";
    "python.analysis.autoSearchPaths" = true;
    "python.analysis.autoImportCompletions" = true;
    "python.analysis.completeFunctionParens" = true;
    "python.analysis.inlayHints.variableTypes" = true;
    "python.analysis.inlayHints.functionReturnTypes" = true;
    "python.analysis.enablePytestSupport" = true;
    "python.analysis.indexing" = true;
    "ruff.lineLength" = 88;
    "ruff.configuration" = "pyproject.toml";
    "[python]" = {
      "editor.formatOnSave" = true;
      "editor.rulers" = [
        88
      ];
      "editor.defaultFormatter" = "charliermarsh.ruff";
      "editor.codeActionsOnSave" = {
        "source.fixAll" = "explicit";
        "source.organizeImports" = "explicit";
      };
    };
    "python.defaultInterpreterPath" = "\${workspaceFolder}/.venv/bin/python";
    "ansible.python.interpreterPath" = "\${workspaceFolder}/.venv/bin/python";
  };
in

{
  home.file.${sourceSettingsPath}.text = vscodeSettingsContent;

  home.packages = [
    (pkgs.python3.withPackages (
      ps: with ps; [
        python-lsp-server
      ]
    ))
    pkgs.ruff
  ];
}

# {
#   xdg.configFile."/home/max/.config/qtile/.vscode/settings.json".source =
#     ./configs/vscode-python/settings.json;

#   home.packages = [
#     (pkgs.python3.withPackages (
#       ps = with ps; [
#         python-lsp-server
#       ]
#     ))
#     pkgs.ruff

#   ];
# }
