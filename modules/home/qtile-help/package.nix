# modules/home/qtile-help/package.nix

{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "qtile-help";
  version = "0.1.0";
  src = ../../home/desktop/qtile/config;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/qtile-config $out/bin

    cp -r $src/* $out/lib/qtile-config/

    makeWrapper ${pkgs.python313}/bin/python3 $out/bin/qtile-help \
      --set QTILE_HELP_INSTALLED "1" \
      --set QTILE_CONFIG_PATH "$out/lib/qtile-config" \
      --prefix PYTHONPATH : "$out/lib/qtile-config" \
      --prefix PYTHONPATH : "$out/lib/qtile-config/modules/qtile_help" \
      --prefix PYTHONPATH : "${pkgs.python313.withPackages (ps: with ps; [ tkinter customtkinter pillow ])}/lib/python3.13/site-packages" \
      --add-flags "-m modules.qtile_help.main"
  '';

  meta.mainProgram = "qtile-help";
}
