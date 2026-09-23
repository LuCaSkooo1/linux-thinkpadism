# Your system's flake. Put this in /etc/nixos next to your configuration.nix.
#
# You should not need to edit it. Everything about your machine stays in
# configuration.nix, exactly as before — this file only adds Thinkpadism.
#
# Rebuild with:
#
#   sudo nixos-rebuild switch --flake /etc/nixos#nixos
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    thinkpadism = {
      url = "github:LuCaSkooo1/linux-thinkpadism";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    thinkpadism,
    ...
  }: {
    # "nixos" is the name you pass to --flake /etc/nixos#nixos. It does not
    # have to match your hostname.
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        thinkpadism.nixosModules.default
      ];
    };
  };
}
