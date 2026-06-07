{
  description = "NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yandex-browser = {
      url = "github:miuirussia/yandex-browser.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    mcp-nixos = {
      url = "github:utensils/mcp-nixos";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      lib = import ./lib { inherit inputs; };
    in
    {
      nixosConfigurations = {
        nixos = lib.mkNixosConfiguration {
          hostName = "nixos";
          hostPath = ./hosts/nixos;
        };
      };
    };
}
