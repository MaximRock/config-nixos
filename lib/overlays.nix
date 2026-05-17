{ inputs }:

let
  inherit (inputs)
    nixpkgs-unstable
    yandex-browser
    nur
    llm-agents
    ;

  system = "x86_64-linux";
in
[
  # pkgs.unstable.* — полный unstable channel
  (final: prev: {
    unstable = import nixpkgs-unstable {
      inherit system;
      config = prev.config // { allowUnfree = true; };
    };
  })

  # pkgs.yandex-browser.* — пакеты из флейка
  (final: prev: {
    yandex-browser = yandex-browser.packages.${system};
  })

  # Внешние overlays
  nur.overlays.default
  llm-agents.overlays.default
]