# modules/home/power_menu/package.nix

{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "qtile-power-menu";
  version = "0.1.0";
  src = ../config;

  presets = ../../../../../lib/theme/presets;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/qtile-config $out/bin

    # Сначала копируем пресеты из shared source (реальные файлы, не симлинки)
    mkdir -p "$out/lib/qtile-config/config_qtile/theme/presets"
    cp $presets/*.json "$out/lib/qtile-config/config_qtile/theme/presets/"

    # Копируем config_qtile, исключая theme/presets
    for d in "$src"/config_qtile/*/; do
      b=$(basename "$d")
      [ "$b" = "theme" ] && continue
      cp -r "$d" "$out/lib/qtile-config/config_qtile/"
    done
    # Копируем theme (кроме presets)
    for d in "$src"/config_qtile/theme/*/; do
      [ "$(basename "$d")" = "presets" ] && continue
      cp -r "$d" "$out/lib/qtile-config/config_qtile/theme/"
    done
    cp -r $src/modules $out/lib/qtile-config/
    cp $src/constants.py $out/lib/qtile-config/
    mkdir -p $out/lib/qtile-config/settings
    cp $src/settings/*.py $out/lib/qtile-config/settings/

    makeWrapper ${pkgs.python313}/bin/python3 $out/bin/qtile-power-menu \
      --set QTILE_POWER_MENU_INSTALLED "1" \
      --prefix PYTHONPATH : "$out/lib/qtile-config" \
      --prefix PYTHONPATH : "$out/lib/qtile-config/modules/power_menu" \
      --prefix PYTHONPATH : "${pkgs.python313.withPackages (ps: with ps; [ tkinter customtkinter pillow ])}/lib/python3.13/site-packages" \
      --add-flags "-m modules.power_menu.main"
  '';

  meta.mainProgram = "qtile-power-menu";
}
