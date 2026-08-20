{ inputs }:

let
  inherit (inputs)
    nixpkgs-unstable
    yandex-browser
    nur
    rime
    yazi
    ;

  system = "x86_64-linux";
in
[
  # pkgs.unstable.* — полный unstable channel
  (final: prev: {
    unstable = import nixpkgs-unstable {
      inherit system;
      config = prev.config // {
        allowUnfree = true;
      };
    };
  })

  # qtile 0.36.0: флейки-тест REPL-сервера в песочнице (ConnectionResetError).
  # Upstream отключил его в 0.37.0 (nixpkgs master, "Client disconnect prematurely")
  (final: prev: {
    python3 = prev.python3.override {
      packageOverrides = pyfinal: pyprev: {
        qtile = pyprev.qtile.overrideAttrs (old: {
          disabledTests = old.disabledTests ++ [ "test_repl_server_executes_code" ];
        });
      };
    };
    # python3Packages — отдельный алиас, привязанный к старому python3
    python3Packages = final.python3.pkgs;
  })

  # pkgs.yandex-browser.* — пакеты из флейка
  (final: prev: {
    yandex-browser = yandex-browser.packages.${system};
  })

  # Внешние overlays
  nur.overlays.default
  rime.overlays.default
  yazi.overlays.default
]
