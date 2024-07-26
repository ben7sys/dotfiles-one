# Load common environment settings
for file in ~/.{env_common,exports}; do
    [ -r "$file" ] && [ -f "$file" ] && . "$file"
fi

# Set PATH so it includes user's private bin if it exists
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"

# Set default editor
export EDITOR=vim

# Set language and locale settings
export LANG=de_DE.UTF-8
export LC_ALL=de_DE.UTF-8

# Load system-specific settings if applicable
[ -r ~/.env_systemd ] && [ -d /run/systemd/system ] && . ~/.env_systemd
[ -r ~/.env_kde ] && [ -d ~/.config/plasma-workspace ] && . ~/.env_kde

# If running bash, include .bashrc if it exists
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"