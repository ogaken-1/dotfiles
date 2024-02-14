show () {
  fd "$1" | xargs bat
}

gitop () {
  cd "$(git rev-parse --show-toplevel)"
}

gcd () {
  if [ -z "$1" ]; then
    PROJECT_PATH="$(ghq list --full-path | fzf)"
    if [ -z "${PROJECT_PATH}" ]; then
      return
    fi
    SESSION_NAME="$(basename ${PROJECT_PATH} | sed -E 's/\./_/g')"
    tmux new-session -d -s "${SESSION_NAME}" -c "${PROJECT_PATH}" || tmux a -t "${SESSION_NAME}"
    if [ -n "${TMUX}" ]; then
      tmux switch-client -t "${SESSION_NAME}"
    else
      tmux a -t "${SESSION_NAME}"
    fi
  else
    cd "$1"
  fi
}

attach () {
  tmux a -t "$(tmux ls | fzf | sed -E 's/\s.\+///')"
}
