{
  description = "Unofficial GeForce NOW Electron app";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages.${system}.geforcenow = pkgs.callPackage ./pkgs/geforcenow.nix {
      lib = pkgs.lib;
      electron = pkgs.electron;
      makeWrapper = pkgs.makeWrapper;
      nodejs = pkgs.nodejs_20;
      yarn = pkgs.yarn;
      src = self + /src;
      mkYarnPackage = pkgs.mkYarnPackage;
      fetchYarnDeps = pkgs.fetchYarnDeps;
      makeDesktopItem = pkgs.makeDesktopItem;
    };

    defaultPackage.${system} = self.packages.${system}.geforcenow;

    devShells.${system}.default = pkgs.mkShell {
      packages = [
        pkgs.nodejs_20
        pkgs.yarn
        pkgs.electron
        pkgs.makeWrapper
      ];
    };
  };
}
