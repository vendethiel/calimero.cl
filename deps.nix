{
  pkgs,
  named-readtables-repo,
  autoload-repo,
}:
let
  # Function to wrap sbcl available package in a cl-lite form
  sbclPackage =
    name: lispDependencies:
    pkgs.lispPackagesLite.lispDerivation {
      lispSystem = name;
      src = pkgs.sbclPackages.${name};
      inherit lispDependencies;
    };

  mgl-pax_dot_asdf = pkgs.lispPackagesLite.lispDerivation {
    lispSystem = "mgl-pax.asdf";
    src = pkgs.sbclPackages.mgl-pax_dot_asdf;
    lispDependencies = [ ];
  };

  autoload = pkgs.lispPackagesLite.lispDerivation {
    lispSystem = "autoload";
    src = autoload-repo;
    lispDependencies = [ mgl-pax_dot_asdf ];
  };

  mgl-pax-bootstrap = sbclPackage "mgl-pax-bootstrap" [
    autoload
    mgl-pax_dot_asdf
  ];

  form-fiddle = sbclPackage "form-fiddle" [
    pkgs.lispPackagesLite.documentation-utils
  ];

  lambda-fiddle = sbclPackage "lambda-fiddle" [ ];

  # there's `pkgs.lispPackagesLite.named-readtables`, but it's not the right version
  named-readtables = pkgs.lispPackagesLite.lispDerivation {
    lispSystem = "named-readtables";
    src = named-readtables-repo;
    lispDependencies = [ mgl-pax-bootstrap ];
  };

  cl-syntax = sbclPackage "cl-syntax" [
    pkgs.lispPackagesLite.trivial-types
    named-readtables
  ];

  fn = sbclPackage "fn" [ named-readtables ];

  for = sbclPackage "for" [
    pkgs.lispPackagesLite.documentation-utils
    form-fiddle
    lambda-fiddle
  ];

  modf = sbclPackage "modf" [
    pkgs.lispPackagesLite.alexandria
    pkgs.lispPackagesLite.closer-mop
    pkgs.lispPackagesLite.iterate
  ];

  cl-reexport = sbclPackage "cl-reexport" [
    pkgs.lispPackagesLite.alexandria
  ];

  cl-punch = sbclPackage "cl-punch" [ cl-syntax ];

  defstar = sbclPackage "defstar" [ ];

in
builtins.attrValues {
  inherit (pkgs.lispPackagesLite)
    alexandria
    serapeum
    access
    closer-mop
    trivial-types
    nclasses
    str
    trivia
    metabang-bind
    cl-interpol
    ;
}
++ [
  named-readtables
  fn
  for
  modf
  cl-reexport
  cl-punch
  defstar
]
