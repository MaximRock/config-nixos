# modules/home/qtile-help/package.nix

{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "qtile-help";
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

    makeWrapper ${pkgs.python313}/bin/python3 $out/bin/qtile-help \
      --set QTILE_HELP_INSTALLED "1" \
      --prefix PYTHONPATH : "$out/lib/qtile-config" \
      --prefix PYTHONPATH : "$out/lib/qtile-config/modules/qtile_help" \
      --prefix PYTHONPATH : "${pkgs.python313.withPackages (ps: with ps; [ tkinter customtkinter pillow ])}/lib/python3.13/site-packages" \
      --add-flags "-m modules.qtile_help.main"
  '';

  meta.mainProgram = "qtile-help";
}
