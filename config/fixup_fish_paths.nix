# Fix some Nix paths not being early enough in $PATH.
# From: https://github.com/LnL7/nix-darwin/issues/122#issuecomment-829046310

{ config, lib, ... }:

with lib;

let
  cfg = config.programs.fish;
in
{
  config = mkIf cfg.enable {
    environment.etc."fish/nixos-env-preinit.fish".text = mkMerge [
      (mkBefore "set -l old_path $PATH")
      (mkAfter ''
        for path_element in $PATH
          if not contains -- $path_element $old_path /usr/local/bin /usr/bin /bin /usr/sbin /sbin
            set -ag fish_user_paths $path_element
          end
        end
        set -el old_path
      '')
    ];
  };
}
