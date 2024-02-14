show () {
  fd "$1" | xargs bat
}

gitop () {
  cd "$(git rev-parse --show-toplevel)"
}
