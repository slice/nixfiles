{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.hh3;

  inherit (builtins) elem;

  inherit (lib) types;

  inherit (lib.attrsets)
    listToAttrs
    filterAttrs
    nameValuePair
    mapAttrs'
    recursiveUpdate
    ;

  inherit (lib.modules) mkOption mkEnableOption mkIf;

  allSupportedBranches = [
    "stable"
    "ptb"
    "canary"
  ];

  renameAttr =
    oldAttrName: newAttrName:
    mapAttrs' (
      name: value:
      if name == oldAttrName then nameValuePair newAttrName value else nameValuePair name value
    );

  branchSubmodule = types.submodule {
    freeformType = types.attrsOf types.anything;

    options.enable = mkOption {
      description = "Whether this branch config is active.";
      type = types.bool;
      default = false;
    };

    options.enabledExts = mkOption {
      description = "A shorthand option to mass-enable extensions without specifying additional options";
      type = types.listOf types.str;
      default = [
        "sentrynerf"
        "loadingScreen"
        "pseudoscience"
      ];
    };

    options.exts = mkOption {
      description = "Extensions";
      type = types.attrsOf (
        types.submodule {
          options = {
            enabled = mkOption {
              description = "Whether this extension is enabled or not";
              type = types.bool;
            };
            options = mkOption {
              description = "This extension's options";
              type = types.attrsOf types.anything;
              default = { };
            };
          };
        }
      );
      default = { };
    };
  };

  branchConfigFilename = branch: "discord${if branch == "stable" then "" else branch}.json";

  configPath =
    branch:
    let
      filename = branchConfigFilename branch;
    in
    if pkgs.stdenv.isDarwin then
      "Library/Application Support/hh3/${filename}"
    else
      ".config/hh3/${filename}";

  # Don't bother creating files for branch configurations that aren't
  # enabled.
  enabledConfigs = filterAttrs (branchName: config: config.enable) cfg.config;

  genConfigJSON =
    branchName: branchConfig:
    let
      generatedEnabledModules = listToAttrs (
        map (moduleName: {
          name = moduleName;
          value.enabled = true;
        }) branchConfig.enabledExts
      );

      generatedBaseConfig = {
        modules = generatedEnabledModules;
      };

      # Prepare the user's configuration to be merged with the generated
      # partial configuration.
      #
      # (1) Rename the `exts` attribute to `modules`. `modules` is the actual
      #     configuration key that HH3 expects, not `exts`. `exts` was chosen
      #     here in order to reduce confusion, as they are almost universally
      #     referred to as "extensions" in all other contexts.
      # (2) Remove the `enabledExts` and `enable` keys, as they are details
      #     of this home-manager module. HH3 should not see them.
      sanitizedUserConfig = renameAttr "exts" "modules" (
        filterAttrs (
          name: value:
          !elem name [
            "enabledExts"
            "enable"
          ]
        ) branchConfig
      );

      # Merge our generated partial configuration with the user's configuration.
      finalConfig = recursiveUpdate generatedBaseConfig sanitizedUserConfig;
    in
    builtins.toJSON finalConfig;
in
{
  options.programs.hh3 = {
    enable = mkEnableOption "hh3";
    config = mkOption {
      description = "Per-branch configs";
      type = types.submodule {
        options = listToAttrs (
          map (branchName: {
            name = branchName;
            value = mkOption {
              type = branchSubmodule;
              default = { };
            };
          }) allSupportedBranches
        );
      };
      default = { };
    };
  };

  config = mkIf cfg.enable {
    home.file = mapAttrs' (
      branch: branchConfig:
      nameValuePair (configPath branch) { text = genConfigJSON branch branchConfig; }
    ) enabledConfigs;
  };
}
