{
  description = "CL development environment for Calimero";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    cl-nix-lite.url = "github:hraban/cl-nix-lite/v0";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      cl-nix-lite,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ cl-nix-lite.overlays.default ];
        };
        thirdParty = pkgs.lib.mapAttrs (
          lispSystem: src:
          pkgs.lispPackagesLite.lispDerivation {
            inherit lispSystem src;
          }
        ) {
          inherit (pkgs.sbclPackages) defstar fn for modf cl-reexport;
        };
      in
      {
        # devShells =
        packages = {
          default =
            with pkgs.lispPackagesLite;
            lispDerivation {
              lispSystem = "calimero";
              lispDependencies = [
                alexandria
                serapeum
                access
                closer-mop
                trivial-types
                nclasses
                named-readtables
                str
                trivia
                metabang-bind
                cl-interpol
                #thirdParty.fn
                #thirdParty.for
                #thirdParty.modf
                #thirdParty.cl-reexport
                thirdParty.defstar
              ];
              src = pkgs.lib.sourceByRegex ./. [ "^src/*.lisp$" ];
            };
          };
      }
    );
}
