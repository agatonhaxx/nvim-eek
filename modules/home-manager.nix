# Home-manager module for nvim-eek.
#
# Imported by the flake with `nvimEekPackages` (the flake's per-system
# `packages` attrset) so the defaults always match the config revision of the
# flake that provides the module.
{ nvimEekPackages }:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.nvim-eek;
  defaults =
    nvimEekPackages.${pkgs.system} or (throw ''
      nvim-eek: no packages for system `${pkgs.system}`.
      Supported systems: ${toString (builtins.attrNames nvimEekPackages)}'');
in
{
  options.programs.nvim-eek = {
    enable = lib.mkEnableOption "nvim-eek, a mini.nvim-based Neovim config";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaults.nvim-eek.override { appName = cfg.appName; };
      description = "The nvim-eek launcher package to install.";
    };

    configPackage = lib.mkOption {
      type = lib.types.package;
      default = defaults.nvim-eek-config;
      description = "The nvim-eek config package to link into the config directory.";
    };

    installPackage = lib.mkOption {
      type = lib.types.package;
      default = defaults.nvim-eek-install.override {
        inherit (cfg) appName configPackage;
      };
      description = "The nvim-eek installer package, run at activation.";
    };

    appName = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "Neovim APPNAME used for the config directory (~/.config/<appName>).";
    };

    installOnActivation = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Run the installer at each activation. It prefetches plugins at the
        revisions pinned in 'nvim-pack-lock.json'; re-running is a no-op until
        the config package changes.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."${cfg.appName}" = {
      source = cfg.configPackage;
    };

    home.activation.nvim-eek = lib.hm.dag.entryAfter [ "writeBoundary" ] (
      lib.optionalString cfg.installOnActivation ''
        run ${cfg.installPackage}/bin/nvim-eek-install
      ''
    );
  };
}
