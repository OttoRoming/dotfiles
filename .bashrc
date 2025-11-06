#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

complete -F _command doas
export MOZ_USE_XINPUT2=1

# Take too much time:
# eval "$(thefuck --alias)"
# . /usr/share/nvm/init-nvm.sh

export PATH="~/.cargo/bin/:${PATH}"
alias w++='g++ -std=c++17 -Wall -Wextra -Wpedantic -Weffc++ -Wold-style-cast -g'

fastfetch
