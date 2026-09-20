{ inputs }:

let
  inherit (inputs)
    nixpkgs-unstable
    yandex-browser
    nur
    rime
    ;

  system = "x86_64-linux";

  # Точечные фиксы flaky-тестов python-пакетов.
  # Применяется к обоим сетам 3.13 (python3Packages и python313Packages),
  # иначе потребители versioned-сета фиксы не увидят.
  # Сам интерпретатор python3 НЕ трогаем: его override меняет хеш
  # и тянет пересборку всего python-экосистемы из исходников.
  pyTestFixes = pyfinal: pyprev: {
    # qtile: флейки-тест REPL-сервера в песочнице (ConnectionResetError).
    # Upstream отключил его в 0.37.0 ("Client disconnect prematurely")
    qtile = pyprev.qtile.overrideAttrs (old: {
      disabledTests = old.disabledTests ++ [ "test_repl_server_executes_code" ];
    });
    # ipython: flaky pexpect-тест в песочнице: Could not terminate the child
    ipython = pyprev.ipython.overridePythonAttrs (old: {
      disabledTests = old.disabledTests ++ [ "test_where_erase_value" ];
    });
    # django: flaky perf-тест test_crafted_xml_performance;
    # runtests.py в installCheckPhase игнорирует disabledTests.
    django = pyprev.django.overridePythonAttrs (old: {
      doCheck = false;
      doInstallCheck = false;
    });
  };
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

  # Точечные python-фиксы (см. pyTestFixes выше) — пересобираются
  # только чиненые пакеты и их reverse-зависимости, остальное из кэша.
  (final: prev: {
    python3Packages = prev.python3Packages.override { overrides = pyTestFixes; };
    python313Packages = prev.python313Packages.override {
      overrides = pyTestFixes;
    };
  })

  # pkgs.yandex-browser.* — пакеты из флейка
  (final: prev: {
    yandex-browser = yandex-browser.packages.${system};
  })

  # pkgs.dyad — обёртка над официальным .deb релиза dyad-sh/dyad
  (final: prev: {
    dyad = final.callPackage ../pkgs/dyad { };
  })

  # Внешние overlays
  nur.overlays.default
  rime.overlays.default
]
