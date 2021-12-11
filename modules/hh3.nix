{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.hh3;
  supportedBranches = [ "stable" "ptb" "canary" ];
  renameAttr = oldAttrName: newAttrName:
    mapAttrs' (name: value:
      if name == oldAttrName then
        nameValuePair newAttrName value
      else
        nameValuePair name value);
in {
  options.programs.hh3 = {
    enable = mkEnableOption "hh3";
    config = let
      branchSubmodule = types.submodule {
        freeformType = types.attrsOf types.anything;

        options.enable = mkOption {
          description = "Whether this branch config is active.";
          type = types.bool;
          default = false;
        };

        options.enabledExts = mkOption {
          description =
            "A shorthand option to mass-enable extensions without specifying additional options";
          type = types.listOf types.str;
          default = [ "sentrynerf" "loadingScreen" "pseudoscience" ];
        };

        options.exts = mkOption {
          description = "Extension options";
          type = types.attrsOf (types.submodule {
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
          });
          default = { };
        };
      };
    in mkOption {
      description = "Per-branch configs";
      type = types.submodule {
        options = listToAttrs (map (branchName: {
          name = branchName;
          value = mkOption {
            type = branchSubmodule;
            default = { };
          };
        }) supportedBranches);
      };
      default = { };
    };
  };

  config = mkIf cfg.enable (let
    branchToFilename = branch:
      let suffix = if branch == "stable" then "" else branch;
      in "discord${suffix}.json";
    configPath = branch:
      let filename = branchToFilename branch;
      in if pkgs.stdenv.isDarwin then
        "Library/Application Support/hh3/${filename}"
      else
        ".config/hh3/${filename}";
  in {
    home.file = mapAttrs' (branch: branchConfig:
      nameValuePair (configPath branch) {
        text = let
          generatedEnabledModules = listToAttrs (map (moduleName: {
            name = moduleName;
            value = { enabled = true; };
          }) branchConfig.enabledExts);
          generatedConfig = { modules = generatedEnabledModules; };
          sanitizedConfig = let
            config =
              filterAttrs (name: value: !elem name [ "enabledExts" "enable" ])
              branchConfig;
          in renameAttr "exts" "modules" config;
        in builtins.toJSON (recursiveUpdate generatedConfig sanitizedConfig);
      }) (filterAttrs (branch: branchConfig: branchConfig.enable) cfg.config);
  });
}
