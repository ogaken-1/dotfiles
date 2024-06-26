set -x XDG_CONFIG_HOME "$HOME/.config"
set -x XDG_DATA_HOME "$HOME/.local/share"
set -x XDG_STATE_HOME "$HOME/.local/state"
set -x XDG_CACHE_HOME "$HOME/.cache"

fish_add_path "$HOME/bin"
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/go/bin"
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.rustup/toolchains/*/bin"
fish_add_path "$HOME/.deno/bin"
fish_add_path "$HOME/.ghcup/bin"
fish_add_path "$HOME/.cabal/bin"
# fsautocompleteなどの dotnet-* ではないツールを使うときに必要になる
fish_add_path "$HOME/.dotnet/tools"

set -x EDITOR 'nvim'
set -x MANPAGER 'nvim +Man!'
set -x SYSTEMD_EDITOR "$EDITOR"
set -x LESSCHARSET 'utf-8'
set -x LANG 'en_US.UTF-8'

set -x PNPM_HOME "$XDG_DATA_HOME/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  fish_add_path $PNPM_HOME
end

if status --is-interactive
  # git
  abbr -a gs 'git status --short --branch -uall'
  abbr -a gsw 'git switch'
  abbr -a ga 'git add'
  abbr -a gd 'git diff'
  abbr -a gst 'git stash'
  abbr -a gci 'git commit'
  abbr -a gcif 'git commit --fixup='
  abbr -a gcia 'git commit --amend'
  abbr -a gp 'git push'
  abbr -a gP 'git pull -p'
  abbr -a gpu 'git push -u origin "$(git branch --show-current)"'
  abbr -a gpf 'git push --force-if-includes --force-with-lease'
  abbr -a gf 'git fetch'

  if [ -z $TMUX ]
    bind \cqs 'tmux attach-session -t (tmux list-sessions -F \'#{session_name}\' 2> /dev/null | fzf --layout=reverse --border=block) > /dev/null 2> /dev/null'
  end

  # tmux
  abbr -a ta 'tmux attach -t'

  function _fishprompt_preexec --on-event fish_preexec
    osc_133 'C'
  end

  function _fishprompt_postexec --on-event fish_postexec
    osc_133 (printf 'D;%d' $status)
  end

  if which direnv > /dev/null
    eval (direnv hook fish)
  end
end
