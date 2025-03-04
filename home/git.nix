{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Skip R";
    userEmail = "tinyslices@gmail.com";

    lfs.enable = true;

    delta = {
      enable = true;
      options = {
        line-numbers = true;
        features = "decorations";
        hyperlinks = true;
        syntax-theme = "zenburn";
        side-by-side = false;
      };
    };

    extraConfig =
      let
        ghHelper = {
          helper = "!${pkgs.gh}/bin/gh auth git-credential";
        };
      in
      {
        # url."git@github.com:".insteadOf = "https://github.com/";
        commit.verbose = true;
        format.pretty = "tformat:%C(bold yellow)%h%Creset %<|(82,trunc)%s %Creset%C(bold white)%cr%C(nobold)/%ch%Creset %C(bold)(%an)%C(auto)%d";
        push.default = "current";
        core.ignorecase = false;
        color.ui = true;
        color.diff.meta = "reverse";
        pull.ff = "only";
        init.defaultBranch = "main";
        branch.sort = "-committerdate";
        # diff.colorMoved = "default";
        "credential \"https://github.com\"" = ghHelper;
        "credential \"https://gist.github.com\"" = ghHelper;
      };

    ignores = [
      "*~"
      "*.swp"
      ".DS_Store"
      "/.yalc" # https://github.com/wclr/yalc
      "__MACOSX"
    ];
  };
}
