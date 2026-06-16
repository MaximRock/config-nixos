{
  description = "Dev environment for qtile config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            uv
            python313
            cairo
            pango
            glib
            gobject-introspection
            libxkbcommon
            libxcb
            xcbutilcursor
            xcbutilkeysyms
            xcbutilwm
            pkg-config
          ];

          shellHook = ''
            echo "🚀 Qtile dev shell activated"
            export UV_PYTHON="${pkgs.python3}/bin/python3"
            export PYTHONPATH="$PWD:$PYTHONPATH"
            
            if [ -d ".venv" ]; then
              export PYTHONPATH="$PWD/.venv/lib/python3.13/site-packages:$PYTHONPATH"
            else
              echo "💡 Run: uv sync"
            fi
          '';
        };
      }
    );
}
