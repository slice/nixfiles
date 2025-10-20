{ pkgs, ... }:

{
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      features = "decorations";
      hyperlinks = true;
      syntax-theme = "zenburn";
      side-by-side = false;
    };
  };

  programs.git = {
    enable = true;

    settings =
      let
        ghCredentialHelper = {
          helper = "!${pkgs.gh}/bin/gh auth git-credential";
        };
      in
      {
        user.name = "Skip R";
        user.email = "tinyslices@gmail.com";

        # url."git@github.com:".insteadOf = "https://github.com/";
        commit.verbose = true;
        format.pretty = "tformat:%C(bold yellow)%h%Creset %<|(82,trunc)%s %Creset%C(bold white)%cr%C(nobold)/%ch%Creset %C(bold)(%an)%C(auto)%d";
        push.default = "current";
        core.ignorecase = false;
        color = {
          ui = true;
          diff.meta = "reverse";
        };
        pull.rebase = true;
        init.defaultBranch = "main";
        branch.sort = "-committerdate";
        # diff.colorMoved = "default";

        "credential \"https://github.com\"" = ghCredentialHelper;
        "credential \"https://gist.github.com\"" = ghCredentialHelper;
      };

    lfs.enable = true;

    includes = [
      {
        path = "~/.config/git/work";
        condition = "gitdir:~/work/";
      }
    ];

    ignores = [
      "*~"
      "*.swp"

      # https://en.wikipedia.org/wiki/AppleSingle_and_AppleDouble_formats
      "._*"
      "__MACOSX"

      # https://en.wikipedia.org/wiki/.DS_Store
      ".DS_Store"

      # https://github.com/wclr/yalc
      "/.yalc"
    ];
  };
}
