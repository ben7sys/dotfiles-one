# ~/.bash_logout: executed by bash(1) when login shell exits

# Clear the screen when leaving the console to increase privacy
if [ "$SHLVL" = 1 ]; then
    # Use clear_console if available, otherwise fall back to clear
    if [ -x /usr/bin/clear_console ]; then
        /usr/bin/clear_console -q
    else
        clear
    fi

    # Optional: Remove temporary files
    if [ -d "$HOME/tmp" ]; then
        rm -rf "$HOME/tmp"/*
    fi

    # Print logout message
    echo "Logging out. Goodbye!"
fi

# Note: Avoid clearing bash history here as it may be undesirable.
# If needed, manage history size in .bashrc instead:
# HISTSIZE=1000
# HISTFILESIZE=2000