{
  config,
  pkgs,
  lib,
  ...
}:

let
  textEditor = config.home.sessionVariables.EDITOR;
  nixfiles = "~/src/prj/nixfiles";
in
{
  programs.fish = {
    enable = true;

    shellAliases = (
      {
        # the usual suspects
        ls = "eza --classify=always";

        # worth noting that aliases resolve within aliases
        ll = "ls --header --long --sort=modified --reverse --time-style=relative --git --created --modified";
        lt = "ll --time-style=iso"; # force absolute timestamps
        la = "ll -aa";

        e = textEditor;
        se = "sudo ${textEditor}";
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        lsregister = "/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister";
        tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      }
    );

    shellAbbrs =
      {
        ipy = "ipython";
        py = "python3";
        bl = "bloop";
        md = "mkdir";
        ydl = "yt-dlp";
        ydle = "yt-dlp -f bestaudio --audio-format mp3 --extract-audio";
        k = "kubectl";

        c = "pbcopy";
        p = "pbpaste";

        merge = "history --merge";

        hms = "hm-switch";
        nds = "nd-switch";
        hmu = "hm-update";
        ndu = "nd-update";

        agp = "autocommit; and git push -v";

        j = "jj";
        jn = "jj new";

        # vcs
        g = "git";
        ga = "git add";
        gap = "git add -p";
        gb = "git branch -vv";
        gc = "git commit";
        gca = "git commit --amend";
        gcl = "git clone";
        gco = "git checkout";
        gcp = "git cherry-pick";
        gd = "git diff";
        gds = "git diff --staged";
        gf = "git fetch";
        gi = "git init";
        gl = "git log";
        gp = "git push";
        gpf = "git push --force-with-lease";
        gpl = "git pull"; # (not the license)
        gr = "git remote";
        grb = "git rebase";
        grbc = "git rebase --continue";
        grba = "git rebase --abort";
        grm = "git rm";
        grs = "git reset";
        gs = "git status";
        gsh = "git show";
        gst = "git stash";
        gsw = "git switch";
        gt = "git tag";
      }
      // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
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
    ];

    interactiveShellInit = builtins.readFile ./config.fish;

    functions =
      {
        # NOTE: MANPAGER (and MANWIDTH) is used instead of this
        # man = {
        #   wraps = "man";
        #   description = "diverts man to neovim";
        #   body = ''
        #     ${lib.getBin pkgs.neovim}/bin/nvim man://$argv[1]
        #   '';
        # };

        stab = ''
          begin
            printf '  '
            ps -e -o user,pid,%cpu,%mem,rss,start,etime,command
          end | fzf --header-lines=1 --preview-window=right,25% --pointer='🔪' | awk "{print \$2}" | xargs -r kill -9
        '';

        spek = ''
          set -l id (random)
          set -l path '/tmp/spectrogram-'(random)'.png'

          echo "creating spek at $path ..."

          sox $argv[1] -n spectrogram -o "$path"
          and open "$path"
        '';

        autocommit = ''
          git commit --allow-empty-message -a -m ""
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

          printf '%s@%s%s ' $USER (set_color --bold) (hostname -s)
          set_color normal

          set -l prompt_character '$'
          set -l prompt_color 'magenta'

          if test "$USER" = "root"
            set prompt_character '#'
            set prompt_color 'red'
          end

          set_color --bold $prompt_color
          printf '%s' (prompt_pwd -full-length-dirs 4 --dir-length 3)
          set_color normal
          set_color --bold white
          printf '%s ' $prompt_character
          set_color normal
        '';

        fish_title = ''
          prompt_pwd --dir-length=0
        '';

        fish_right_prompt = ''
          # set this so we can compare the value pre-command_duration (which modifies
          # it)
          set -l _status $status

          command_duration

          # set -l clock (date -Iminutes)
          # set_color -i brblack; printf ' %s' $clock; set_color normal

          printf '%s%s%s' (set_color -o blue) (fish_git_prompt) (set_color normal)

          if test $_status -eq 0
            printf ' %s:O3%s' (set_color green) (set_color normal)
          else
            # set -l face (random choice 'O_O' 'O_o' '>_>' 'v_v' ';_;')
            printf ' %s%s %s:O[%s' (set_color -o red) $_status (set_color -ro red) (set_color normal)
          end
        '';
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        unquarantine = ''
          xattr -dr com.apple.quarantine $argv
        '';

        hm-update = ''
          git -C ${nixfiles} pull -v --autostash
          and hm-switch
        '';

        nd-update = ''
          git -C ${nixfiles} pull -v --autostash
          and nd-switch
        '';

        nd-switch = ''
          set -l hostname_sans_local (string split -f1 '.' (hostname))
          set -l flake_src ${nixfiles}

          nix build $flake_src#darwinConfigurations.$hostname_sans_local.system --verbose $argv
          and ./result/sw/bin/darwin-rebuild switch --flake $flake_src
          and unlink result
        '';

        hm-switch = ''
          home-manager switch --flake ${nixfiles}
        '';
      };
  };
}
