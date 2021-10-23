{ ... }:

{
  programs.git = {
    enable = true;
    userName = "slice";
    userEmail = "tinyslices@gmail.com";

    delta = {
      enable = true;
      options = {
        line-numbers = true;
        features = "decorations";
        syntax-theme = "ansi";
      };
    };

    extraConfig = {
      commit.verbose = true;
      format.pretty = "format:%C(yellow)%h%Creset %s %C(bold)(%an, %cr)%C(green)%d%Creset";
      push.default = "current";
      core.ignorecase = false;
      color.ui = true;
      pull.ff = "only";
      init.defaultBranch = "main";
      # diff.colorMoved = "default";
    };

    ignores = [ "*~" "*.swp" ".DS_Store" "__MACOSX" ];
  };
}
