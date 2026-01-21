{
  description = "CL development environment for Calimero";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    cl-nix-lite.url = "github:hraban/cl-nix-lite/v0";
    named-readtables-repo = {
      url = "github:melisgl/named-readtables";
      flake = false;
    };
    autoload-repo = {
      url = "github:melisgl/mgl-pax?dir=autoload";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      cl-nix-lite,
      named-readtables-repo,
      autoload-repo,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ cl-nix-lite.overlays.default ];
        };

        calimeroDeps = import ./deps.nix {
          inherit pkgs named-readtables-repo autoload-repo;
        };

        calimero = pkgs.lispPackagesLite.lispDerivation {
          lispSystem = "calimero";
          src = pkgs.lib.cleanSource ./.;
          lispDependencies = calimeroDeps;
        };

        calimero-tests = pkgs.lispPackagesLite.lispDerivation {
          lispSystem = "calimero-tests";
          src = pkgs.lib.cleanSource ./.;
          lispDependencies = [
            calimero
            pkgs.lispPackagesLite.fiveam
          ];
        };
      in
      {
        packages = {
          default = calimero;
          inherit calimero calimero-tests;
        };
      }
    );
}
