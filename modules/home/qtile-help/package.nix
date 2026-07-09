# modules/home/qtile-help/package.nix

{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "qtile-help";
  version = "0.1.0";
  src = ../../home/desktop/qtile/config;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/qtile-config $out/bin

    # Копируем всю qtile-конфигурацию, кроме settings/settings.json
    # (читается из ~/.config/qtile/ через fallback в app.py)
    cp -r $src/config_qtile $out/lib/qtile-config/
    cp -r $src/modules $out/lib/qtile-config/
    cp $src/constants.py $out/lib/qtile-config/
    mkdir -p $out/lib/qtile-config/settings
    cp $src/settings/*.py $out/lib/qtile-config/settings/

    makeWrapper ${pkgs.python313}/bin/python3 $out/bin/qtile-help \
      --set QTILE_HELP_INSTALLED "1" \
      --prefix PYTHONPATH : "$out/lib/qtile-config" \
      --prefix PYTHONPATH : "$out/lib/qtile-config/modules/qtile_help" \
      --prefix PYTHONPATH : "${pkgs.python313.withPackages (ps: with ps; [ tkinter customtkinter pillow ])}/lib/python3.13/site-packages" \
      --add-flags "-m modules.qtile_help.main"
  '';

  meta.mainProgram = "qtile-help";
}
