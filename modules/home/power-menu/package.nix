# modules/home/power_menu/package.nix

{ pkgs, ... }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "qtile-power-menu";
  version = "0.1.0";
  src = ../../home/desktop/qtile/config;

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/qtile-config $out/bin

    # Кладём всю qtile-конфигурацию (там находятся modules/, settings/, constants.py)
    cp -r $src/* $out/lib/qtile-config/

    # Wrapper: запускаем как модуль, PYTHONPATH указывает на nix store
    makeWrapper ${pkgs.python313}/bin/python3 $out/bin/qtile-power-menu \
      --set QTILE_POWER_MENU_INSTALLED "1" \
      --set QTILE_CONFIG_PATH "$out/lib/qtile-config" \
      --prefix PYTHONPATH : "$out/lib/qtile-config" \
      --prefix PYTHONPATH : "$out/lib/qtile-config/modules/power_menu" \
      --prefix PYTHONPATH : "${pkgs.python313.withPackages (ps: with ps; [ tkinter customtkinter pillow ])}/lib/python3.13/site-packages" \
      --add-flags "-m modules.power_menu.main"
  '';

  meta.mainProgram = "qtile-power-menu";
}
