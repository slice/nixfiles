{ config, pkgs, ... }:

let textEditor = config.home.sessionVariables.EDITOR;
in {
  programs.fish = {
    enable = true;

    shellAliases = {
      # the usual suspects
      ls = "ls --color=auto -Fh";
      ll = "ls -l";
      la = "ls -al";

      e = textEditor;
      se = "sudo ${textEditor}";
    };

    shellAbbrs = {
      ipy = "ipython";
      py = "python3";
      bl = "bloop";
      md = "mkdir";
      ydl = "yt-dlp";
      ydle = "yt-dlp -f bestaudio --audio-format mp3 --extract-audio";

      # vcs
      g = "git";
      gi = "git init";
      gap = "git add -p";
      ga = "git add";
      grb = "git rebase";
      gca = "git commit --amend";
      gcp = "git cherry-pick";
      gc = "git commit";
      gco = "git checkout";
      gr = "git remote";
      gd = "git diff";
      gds = "git diff --staged";
      gt = "git tag";
      gst = "git stash";
      gsh = "git show";
      gp = "git push";
      gpf = "git push --force";
      gpl = "git pull"; # (not the license)
      gs = "git status";
      gsw = "git switch";
      gl = "git log";
      grm = "git rm";
      gb = "git branch";
      gcl = "git clone";
      grs = "git reset";
    } // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
      sc = "sudo systemctl";
      scs = "sudo systemctl status";
      sce = "sudo systemctl enable";
      scen = "sudo systemctl enable --now";
      scd = "sudo systemctl disable";
      scdn = "sudo systemctl disable --now"; # oh no
      scu = "systemctl --user";
      jc = "sudo journalctl";
      jcu = "sudo journalctl -u";
    };

    plugins = [
      ({
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "45a9ff6d0932b0e9835cbeb60b9794ba706eef10";
          sha256 = "1kjyl4gx26q8175wcizvsm0jwhppd00rixdcr1p7gifw6s308sd5";
        };
      })
      ({
        name = "nix-env";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
          sha256 = "sha256-RG/0rfhgq6aEKNZ0XwIqOaZ6K5S4+/Y5EEMnIdtfPhk=";
        };
      })
    ];

    interactiveShellInit = builtins.readFile ./config.fish;

    functions = {
      spek = ''
        set -l id (random)
        set -l path '/tmp/spectrogram-'(random)'.png'

        echo "creating spek at $path ..."

        sox $argv[1] -n spectrogram -o "$path"
        and open "$path"
      '';

      autocommit = ''
        git commit -a -m (date)
      '';

      fish_greeting = "";

      # used in the fish_right_prompt
      command_duration = ''
        # derived from: https://github.com/jichu4n/fish-command-timer/blob/master/conf.d/fish_command_timer.fish
        set -l second 1000
        set -l minute 60000
        set -l hour 3600000
        set -l day 86400000

        set -l num_days (math -s0 "$CMD_DURATION / $day")
        set -l num_hours (math -s0 "$CMD_DURATION % $day / $hour")
        set -l num_mins (math -s0 "$CMD_DURATION % $hour / $minute")
        set -l num_secs (math -s0 "$CMD_DURATION % $minute / $second")
        set -l time_str ""

        if [ $num_days -gt 0 ]
          set time_str {$time_str}{$num_days}"d "
        end
        if [ $num_hours -gt 0 ]
          set time_str {$time_str}{$num_hours}"h "
        end
        if [ $num_mins -gt 0 ]
          set time_str {$time_str}{$num_mins}"m "
        end

        set time_str {$time_str}{$num_secs}s

        if test "$time_str" != "0s"
          set_color -o yellow
          printf "%s" $time_str
          set_color normal
        end
      '';

      fish_prompt = ''
        # if we're in ssh, show username and hostname
        if set -q SSH_CONNECTION
          set_color yellow
        end

        printf '%s@%s%s ' $USER (set_color -o) (hostname -s)
        set_color normal

        set -l prompt_character '>'
        set -l prompt_color '80c'

        if test "$USER" = "root"
          set prompt_character '#'
          set prompt_color 'red'
        end

        set_color eee -b 80c
        printf '%s' (prompt_pwd -D4)
        set_color normal
        set_color -o $prompt_color
        printf '%s ' $prompt_character
        set_color normal
      '';

      fish_title = ''
        prompt_pwd --dir-length=0
      '';

      fish_right_prompt = ''
        # set this so we can compare the value pre-command_duration (which modifies
        # it)
        set -l _status "$status"

        command_duration

        set -l clock (date -Iminutes)
        set_color -i brblack; printf ' %s' $clock; set_color normal

        printf '%s%s%s' (set_color -o blue) (fish_git_prompt) (set_color normal)

        if test "$_status" -eq 0
          printf ' %s:)%s' (set_color green) (set_color normal)
        else
          # set -l face (random choice 'O_O' 'O_o' '>_>' 'v_v' ';_;')
          printf ' %s:(%s' (set_color -r -o red) (set_color normal)
        end
      '';
    } // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
      unquarantine = ''
        xattr -dr com.apple.quarantine $argv
      '';

      nd-switch = ''
        set hostname_sans_local (string split -f1 '.' (hostname))
        set flake_src ~/src/prj/nixfiles

        nix build $flake_src#darwinConfigurations.$hostname_sans_local.system --verbose $argv
        and ./result/sw/bin/darwin-rebuild switch --flake $flake_src
        and unlink result
      '';

      hm-switch = ''
        home-manager switch --flake ~/src/prj/nixfiles
      '';
    };
  };
}
