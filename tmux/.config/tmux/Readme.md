# TMUX Configuration
This repository contains my personal tmux configuration, optimized for a seamless terminal experience. Below, you'll find an overview of the key features and how to set it up.

## Features

- Optimized for use with Wayland, supporting clipboard integration.
- Provides a comfortable and efficient terminal environment.
- Vim-like keybindings for navigating panes and copying text.
- Mouse support for interactive use.
- Handy plugins for enhanced functionality.

## Prerequisites

Before you can use this configuration, make sure you have the following installed:

- [tmux](https://github.com/tmux/tmux) - Terminal multiplexer.
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard) - Clipboard manager for Wayland.

## configuration

- Install tmux 
    ```shell
    git clone https://github.com/tmux/tmux.git
    cd tmux
    sh autogen.sh
    ./configure && make
    ```
- Install TPM( tmux plugin manager):
    ```shell
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ```
- configure TPM:
    ```shell
    List of plugins
    set -g @plugin 'tmux-plugins/tpm'
    set -g @plugin 'tmux-plugins/tmux-sensible
    ``` 
Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
    ```shell
           run '~/.tmux/plugins/tpm/tpm'
    ```
Reload TMUX environment so TPM is sourced:
    ```shell
    # type this in terminal if tmux is already running in tmux command prompt
    tmux source ~/.tmux.conf
    ```

## Key Bindings
- Ctrl-a as the prefix key. 
- Vim-like keybindings for pane navigation and copying text.
- Enhanced pane resizing with H, J, K, and L (Vim-style).
- Mouse support enabled for easy interaction.

## Usage

- Use Ctrl-a followed by a command key to perform various actions. For example, Ctrl-a + c creates a new window.
- Vim-like keybindings in copy mode: v for visual selection, y for copy to clipboard, and more.
- Resize panes using H, J, K, and L in copy mode (Vim-style).
- Toggle between vertical and horizontal pane splits with | and -.
- Reload the tmux configuration with Ctrl-a + r.

## Plugins

- Tmux Plugin Manager (TPM): Manages and simplifies the installation of additional plugins.
- Tmux Sensible: A set of sensible configurations for a better default tmux experience.

# Acknowledgments
This tmux configuration is inspired by various open-source projects and the contributions of the tmux community. Special thanks to them for making this setup possible.

Happy terminal multiplexing!
