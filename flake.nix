{
  description = "Linux Thinkpadism — a red-accented retro Hyprland desktop for a ThinkPad, on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Per-model hardware quirks: the right kernel modules, microcode and
    # i915 options for a T420, maintained by people who own one.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    ...
  } @ inputs: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = fn: nixpkgs.lib.genAttrs systems (system: fn nixpkgs.legacyPackages.${system});

    # Change this and the directory under hosts/ to rename the machine.
    username = "lucas";
  in {
    ###################################################################
    # The whole machine
    #
    #   sudo nixos-rebuild switch --flake .#t420
    #
    # That one command builds the system, the user environment and the
    # desktop together. There is no second step.
    ###################################################################
    nixosConfigurations.t420 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {inherit inputs username;};

      modules = [
        ./hosts/t420

        (import ./nix/nixos.nix self)

        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {inherit inputs username;};
            users.${username} = import ./home;

            # Move a file Home Manager would otherwise refuse to
            # overwrite out of the way, rather than failing the switch.
            backupFileExtension = "hm-bak";
          };
        }
      ];
    };

    ###################################################################
    # Individual pieces, for use in someone else's configuration
    ###################################################################
    packages = forAllSystems (pkgs: rec {
      # The shell itself: quickshell wrapped so it always launches this
      # config.
      thinkpadism = pkgs.callPackage ./nix/package.nix {};

      thinkpadism-icons = pkgs.callPackage ./nix/icon-theme.nix {};
      thinkpadism-gtk-theme = pkgs.callPackage ./nix/gtk-theme.nix {};
      thinkpadism-wallpapers = pkgs.callPackage ./nix/wallpapers.nix {};

      thinkpadism-neovim = import ./nix/neovim.nix {
        inherit pkgs;
        inherit (pkgs) lib;
      };

      default = thinkpadism;
    });

    homeManagerModules = rec {
      thinkpadism = import ./nix/hm/default.nix self;
      default = thinkpadism;
    };

    nixosModules = rec {
      thinkpadism = import ./nix/nixos.nix self;
      default = thinkpadism;
    };

    ###################################################################
    # Development
    ###################################################################
    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          # `qmlls` for editor support; point your language server at it
          # with `which qmlls`.
          kdePackages.qtdeclarative
          kdePackages.qt5compat
          quickshell

          # Recolouring the icon theme and generating the GTK themes.
          (python3.withPackages (ps: [ps.pillow]))

          # Formatting and checking this flake.
          alejandra
          nixd
          statix
          deadnix

          # Checking the Lua by hand.
          lua-language-server
          stylua
        ];

        shellHook = ''
          echo "Thinkpadism dev shell."
          echo "  quickshell -p ./configs/quickshell        run the shell against this checkout"
          echo "  python3 scripts/make-gtk-themes.py --check  preview the GTK theme generation"
          echo "  python3 scripts/recolor-icons.py --check    preview the icon recolour"
          echo "  nix flake check                            evaluate everything"
        '';
      };
    });

    formatter = forAllSystems (pkgs: pkgs.alejandra);
  };
}
