{
  config,
  flaky,
  lib,
  supportedSystems,
  ...
}: {
  project = {
    name = "bradix";
    summary = "Braille-radix numbers";
  };

  ## dependency management
  services.renovate.enable = true;

  ## development
  programs = {
    direnv.enable = true;
    git.enable = true;
  };

  ## formatting
  editorconfig.enable = true;
  programs = {
    treefmt.enable = true;
    vale = {
      enable = true;
      vocab.${config.project.name}.accept = [
        "[Bb]radix"
        "dozenal"
        "hexidecimal"
        "unary"
      ];
    };
  };

  ## CI
  services.garnix.enable = true;

  ## publishing
  services.flakehub.enable = true;
  services.github.enable = true;
}
