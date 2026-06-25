

{ lib
, python3
, pkgs
}:

python3.pkgs.buildPythonApplication {
  pname = "mcp-dotfiles-helper";
  version = "0.1.0";
  
  src = ./.;
  
  pyproject = true;
  
  build-system = with python3.pkgs; [
    setuptools
  ];
  
  propagatedBuildInputs = with python3.pkgs; [
    mcp
  ];
  
  meta = with lib; {
    description = "MCP server for ~/.dotfiles";
    license = licenses.mit;
  };
}