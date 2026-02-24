alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export MOZ_USE_XINPUT2=1

# export PATH="~/.cargo/bin/:${PATH}"
# export PATH="~/.config/bin/:${PATH}"
alias w++='g++ -std=c++17 -Wall -Wextra -Wpedantic -Weffc++ -Wold-style-cast -g'
alias t="alacritty & disown"

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

fastfetch
export EDITOR=vim
export MAKEFLAGS="-j$(nproc)"
