{
  description = "Unofficial GeForce NOW Electron app";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    node-modules = pkgs.mkYarnPackage {
      name = "node-modules";
      src = ./src;
    };
  in {
    packages.${system}.geforcenow = pkgs.callPackage ./pkgs/geforcenow.nix {
      lib = pkgs.lib;
      electron = pkgs.electron;
      makeWrapper = pkgs.makeWrapper;
      nodejs = pkgs.nodejs_20;
      yarn = pkgs.yarn;
      src = self + /src;
      node-modules = node-modules;
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
