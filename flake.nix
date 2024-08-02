{
  description = "Braille-radix numbers";

  nixConfig = {
    ## https://github.com/NixOS/rfcs/blob/master/rfcs/0045-deprecate-url-syntax.md
    extra-experimental-features = ["no-url-literals"];
    extra-substituters = ["https://cache.garnix.io"];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
    ## Isolate the build.
    registries = false;
    sandbox = "relaxed";
  };

  outputs = {
    elisp-reader,
    flake-utils,
    flaky,
    nixpkgs,
    self,
  }: let
    pname = "bradix";
    ename = "emacs-${pname}";

    supportedSystems = flaky.lib.defaultSystems;
  in
    {
      schemas = {
        inherit
          (flaky.schemas)
          overlays
          homeConfigurations
          packages
          devShells
          projectConfigurations
          checks
          formatter
          ;
      };

      overlays = {
        default = flaky.lib.elisp.overlays.default self.overlays.emacs;

        emacs = final: prev: efinal: eprev: {
          "${pname}" = self.packages.${final.system}.${ename};
        };
      };

      homeConfigurations =
        builtins.listToAttrs
        (builtins.map
          (flaky.lib.homeConfigurations.example self [
            ({pkgs, ...}: {
              programs.emacs = {
                enable = true;
                extraConfig = "(require '${pname})";
                extraPackages = epkgs: [epkgs.${pname}];
              };
            })
          ])
          supportedSystems);
    }
    // flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          elisp-reader.overlays.default
          flaky.overlays.elisp-dependencies
        ];
      };

      src = pkgs.lib.cleanSource ./.;
    in {
      packages = {
        default = self.packages.${system}.${ename};
        "${ename}" = flaky.lib.elisp.package pkgs src pname (epkgs: [
          epkgs.buttercup
          epkgs.elisp-reader
        ]);
      };

      projectConfigurations =
        flaky.lib.projectConfigurations.default {inherit pkgs self;};

      devShells =
        self.projectConfigurations.${system}.devShells
        // {default = flaky.lib.devShells.default system self [] "";};

      checks =
        self.projectConfigurations.${system}.checks
        // {
          elisp-doctor = flaky.lib.elisp.checks.doctor pkgs src;
          elisp-lint = flaky.lib.elisp.checks.lint pkgs src (epkgs: [
            epkgs.elisp-reader
          ]);
        };

      formatter = self.projectConfigurations.${system}.formatter;
    });

  inputs = {
    ## Flaky should generally be the source of truth for its inputs.
    flaky.url = "github:sellout/flaky";

    flake-utils.follows = "flaky/flake-utils";
    nixpkgs.follows = "flaky/nixpkgs";

    elisp-reader = {
      inputs.flaky.follows = "flaky";
      ## TODO: Stop using my fork
      url = "github:sellout/elisp-reader.el/add-build";
    };
  };
}
