{
  description = "Linux Thinkpadism — a red, retro Hyprland desktop for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"];
  in {
    # The desktop. Add it to your flake and set thinkpadism.enable = true.
    nixosModules.default = import ./modules/nixos.nix {inherit self home-manager;};

    # `nix flake init -t github:LuCaSkooo1/linux-thinkpadism` drops a
    # ready flake.nix next to your existing configuration.nix.
    templates.default = {
      path = ./template;
      description = "A flake.nix that adds Thinkpadism to your /etc/nixos";
    };

    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in rec {
      thinkpadism = pkgs.callPackage ./pkgs/package.nix {};
      thinkpadism-icons = pkgs.callPackage ./pkgs/icon-theme.nix {};
      thinkpadism-gtk-theme = pkgs.callPackage ./pkgs/gtk-theme.nix {};
      thinkpadism-wallpapers = pkgs.callPackage ./pkgs/wallpapers.nix {};
      default = thinkpadism;
    });

    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
