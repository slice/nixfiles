if test -n "$maintain_ssh_agent"
  set -l retainer_file ~/.ssh-agent
  if pgrep ssh-agent >/dev/null
    # agent already running, attempt to source file
    if test -f $retainer_file
      head -n 2 $retainer_file | source
    else
      echo "error: ssh-agent running, but $retainer_file doesn't exist! D:"
    end
  else
    # agent not running; spawn it
    echo "agent not running yet, spawning! o/"
    ssh-agent -c > ~/.ssh-agent
    source ~/.ssh-agent
  end
end

if begin; test -d /opt/homebrew; and not set -q DONT_SETUP_HOMEBREW; end
  eval (/opt/homebrew/bin/brew shellenv)
end

# colors
set fish_color_normal normal
set fish_color_command green
set fish_color_quote brblue
set fish_color_redirection yellow
set fish_color_end yellow
set fish_color_error red --bold
set fish_color_param blue
set fish_color_comment brblack
set fish_color_match --background=brblue
set fish_color_selection white --background=brblack
set fish_color_search_match bryellow --background=brblack
set fish_color_operator magenta
set fish_color_escape blue --bold
# fish_color_cwd
set fish_color_autosuggestion brblack
# fish_color_user
# fish_color_host
set fish_color_cancel --reverse
set fish_pager_color_prefix normal --bold
set fish_pager_color_completion normal
set fish_pager_color_description blue
set fish_pager_color_progress normal --background=brblack
# fish_pager_color_secondary

# kitty terminal integration (not using home-manager's management of that
# here because we aren't managing kitty with it atm, and we need to do this
# in the first place because kitty doesn't seem to autodetect fish when
# we call it straight from ~/.nix-profile)
if set -q KITTY_INSTALLATION_DIR
  set --global KITTY_SHELL_INTEGRATION enabled
  source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
  set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
  alias ssh="kitty +kitten ssh"
end
