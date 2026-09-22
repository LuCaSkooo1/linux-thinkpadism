{
  description = "Linux Thinkpadism — a red-accented retro Quickshell desktop for Hyprland on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: fn nixpkgs.legacyPackages.${system});
  in {
    packages = forAllSystems (pkgs: rec {
      # The shell itself: quickshell wrapped so it always launches this config.
      thinkpadism = pkgs.callPackage ./nix/package.nix {};

      thinkpadism-icons = pkgs.callPackage ./nix/icon-theme.nix {};
      thinkpadism-gtk-theme = pkgs.callPackage ./nix/gtk-theme.nix {};
      thinkpadism-wallpapers = pkgs.callPackage ./nix/wallpapers.nix {};

      default = thinkpadism;
    });

    homeManagerModules = rec {
      thinkpadism = import ./nix/home-manager.nix self;
      default = thinkpadism;
    };

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # `qmlls` for editor support; point your language server at it with
          # `which qmlls`.
          kdePackages.qtdeclarative
          kdePackages.qt5compat
          quickshell

          # Recoloring the icon theme.
          (python3.withPackages (ps: [ps.pillow]))

          # Formatting and checking this flake.
          alejandra
          nixd
        ];

        shellHook = ''
          echo "Thinkpadism dev shell."
          echo "  quickshell -p ./configs/quickshell   run the shell against the repo"
          echo "  python3 scripts/recolor-icons.py --check   preview the icon recolor"
        '';
      };
    });

    formatter = forAllSystems (pkgs: pkgs.alejandra);
  };
}
