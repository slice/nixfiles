# vi: set foldmethod=marker:

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

set -l homebrew /opt/homebrew
if test -d $homebrew; and not set -q DONT_SETUP_HOMEBREW
  eval ($homebrew/bin/brew shellenv)
end

# stolen from Fish 3.6.0 release notes: https://fishshell.com/docs/current/relnotes.html#id9
# (hey, it seems useful)
function multicd
    echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end

abbr --add dotdot --regex '^\.\.+$' --function multicd

# colors {{{
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
# }}}

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

# ghostty terminal integration (automatic detection doesn't seem to work :/)
if set -q GHOSTTY_RESOURCES_DIR
  source $GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish
end

if test -f ~/.iterm2_shell_integration.fish
  source ~/.iterm2_shell_integration.fish
end

# MANPATH {{{
# don't let other programs smash $MANPATH (e.g. Ghostty)
set --erase MANPATH

function m
  for p in $argv; test -d $p; and set --export --global --append MANPATH $p; end
end

#m /opt/homebrew/share/man
m ~/.nix-profile/share/man

m /Applications/Xcode{-beta,}.app/Contents/Developer{ \
  /Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/share/man/, \
  /usr/share/man, \
  /Toolchains/XcodeDefault.xctoolchain/usr/share/man \
}

# system programs programs
m /run/current-system/sw/share/man # this subsumes the below
#m /nix/var/nix/profiles/default/share/man # nix CLI pages
m /usr/local/share/man
m /usr/share/man
functions --erase m
# }}}

# directly manipulate PATH such that Nix bin paths are _always_ consulted first
# /run/wrappers/bin is important on NixOS, but is ~irrelevant on nix-darwin
fish_add_path -mP ~/.nix-profile/bin /run/wrappers/bin /run/current-system/sw/bin

set -ga CDPATH .

for employer in ~/src/work/*
  set -ga CDPATH $employer
end

test -d ~/src; and set -ga CDPATH ~/src{/prj,/lib,/scraps,}
test -d ~/Developer; and set -ga CDPATH ~/Developer{/prj,/lib,/scraps,}
