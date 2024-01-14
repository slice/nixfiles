{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Skip R";
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
      format.pretty =
        "tformat:%C(bold yellow)%h%Creset %<|(82,trunc)%s %Creset%C(bold white)%cr%C(nobold)/%ch%Creset %C(bold)(%an)%C(auto)%+d";
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
