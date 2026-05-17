# modules/editors/var-editors.nix
{ username ? "max" }:

{
    vscodeWorkspaceDir = ".dotfiles/.vscode";
    vscodeSettingsFile = "settings.json";

    vscodeWorkspacePython = "/home/${username}/.config/qtile/.vscode";

    configsDir = "./configs";

    flakePath = "/home/${username}/.dotfiles";
    hostName = "nixos";

}
