# exaが入ってるときはlsでexaを使う
if which eza &> /dev/null; then
  alias ls="eza --icons"
fi

# シェルからEmacsを起動するときはTUIを起動する
alias emacs='emacs -nw'
