{
  description = "Braille-radix numbers";

  nixConfig = {
    ## https://github.com/NixOS/rfcs/blob/master/rfcs/0045-deprecate-url-syntax.md
    extra-experimental-features = ["no-url-literals"];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    extra-trusted-substituters = ["https://cache.garnix.io"];
    ## Isolate the build.
    registries = false;
    sandbox = true;
  };

  outputs = inputs: let
    pname = "bradix";
    ename = "emacs-${pname}";
  in
    {
      overlays = {
        default =
          inputs.flaky.lib.elisp.overlays.default inputs.self.overlays.emacs;

        emacs = final: prev: efinal: eprev: {
          "${pname}" = inputs.self.packages.${final.system}.${ename};
        };
      };

      homeConfigurations =
        builtins.listToAttrs
        (builtins.map
          (inputs.flaky.lib.homeConfigurations.example
            pname
            inputs.self
            [
              ({pkgs, ...}: {
                home.packages = [
                  (pkgs.emacsWithPackages (epkgs: [
                    epkgs.${pname}
                  ]))
                ];
              })
            ])
          inputs.flake-utils.lib.defaultSystems);
    }
    // inputs.flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [
          inputs.elisp-reader.overlays.default
          inputs.flaky.overlays.elisp-dependencies
        ];
      };

      src = pkgs.lib.cleanSource ./.;

      format = inputs.flaky.lib.format pkgs {};
    in {
      packages = {
        default = inputs.self.packages.${system}.${ename};
        "${ename}" = inputs.flaky.lib.elisp.package pkgs src pname (epkgs: [
          epkgs.elisp-reader
        ]);
      };

      devShells.default =
        inputs.flaky.lib.devShells.default pkgs inputs.self [] "";

      checks = {
        elisp-doctor = inputs.flaky.lib.elisp.checks.doctor pkgs src;
        elisp-lint = inputs.flaky.lib.elisp.checks.lint pkgs src (epkgs: [
          epkgs.elisp-reader
        ]);
        format = format.check inputs.self;
      };

      formatter = format.wrapper;
    });

  inputs = {
    elisp-reader = {
      inputs.nixpkgs.follows = "nixpkgs";
      ## TODO: Stop using my fork
      url = "github:sellout/elisp-reader.el/add-build";
    };

    flake-utils.url = "github:numtide/flake-utils";

    flaky.url = "github:sellout/flaky";

    nixpkgs.url = "github:NixOS/nixpkgs/release-23.11";
  };
}
