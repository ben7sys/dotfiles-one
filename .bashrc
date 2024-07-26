#
# ~/.bashrc
#

# Run fastfetch on terminal start if available
if command -v fastfetch &> /dev/null; then
    fastfetch
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load common settings
for file in ~/.{env_common,aliases,exports,functions}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

# Load system-specific settings
[ -r ~/.env_systemd ] && [ -d /run/systemd/system ] && source ~/.env_systemd
[ -r ~/.env_kde ] && [ -d ~/.config/plasma-workspace ] && source ~/.env_kde

# Bash-specific settings
shopt -s histappend  # Append to the history file, don't overwrite it
shopt -s checkwinsize  # Check the window size after each command and update LINES and COLUMNS if necessary

# Enable bash-completion if available
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Compact Fancy Bash Prompt Configuration

# Colors
RESET="\[\033[0m\]"
RED="\[\033[0;31m\]"
GREEN="\[\033[0;32m\]"
YELLOW="\[\033[0;33m\]"
BLUE="\[\033[0;34m\]"
MAGENTA="\[\033[0;35m\]"
CYAN="\[\033[0;36m\]"

# Git branch function
git_branch() {
    local branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    [ -n "$branch" ] && echo " ($branch)"
}

# Python virtual environment function
venv_info() {
    [ -n "$VIRTUAL_ENV" ] && echo " ($(basename $VIRTUAL_ENV))"
}

# Exit status function
exit_status() {
    local exit_code=$?
    local symbol="${GREEN}✓${RESET}"
    [ $exit_code -ne 0 ] && symbol="${RED}✗${RESET}"
    echo -e "$symbol"
}

# Set the corrected compact fancy prompt
PROMPT_COMMAND='PS1="${CYAN}\u${RESET}@${GREEN}\h${RESET} ${YELLOW}\W${RESET}${RED}$(git_branch)${BLUE}$(venv_info)${RESET} $(exit_status) ${MAGENTA}▶${RESET} "'

# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi