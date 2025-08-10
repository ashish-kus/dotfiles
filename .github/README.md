# 🏠 Dotfiles

<p align="center">
  <img src="../assets/Preview/Preview-0.png" alt="My Setup Demo" width="600">
</p>

A comprehensive collection of configuration files for my Linux desktop environment, featuring Hyprland as the primary window manager with a curated set of tools and applications.

## 🖥️ System Overview

<p align="center">
  <img src="../assets/Preview/Preview-0.png" alt="My Setup Demo" width="600">
</p>

This dotfiles repository contains configurations for a modern Linux desktop setup built around:

- **Window Manager**: Hyprland (Wayland compositor)
- **Terminal**: Foot & Kitty
- **Shell**: Zsh with Starship prompt
- **Editor**: Vim
- **Application Launcher**: Rofi
- **Status Bar**: Waybar
- **Notification Daemon**: Mako
- **PDF Reader**: Zathura
- **Video Player**: MPV

## 🎨 Color Scheme

The color scheme across all applications is generated using **Huegen**, a custom theme generator that ensures consistent colors throughout the entire desktop environment. This provides a cohesive visual experience across terminals, status bars, application launchers, and all other configured applications.

## 🚀 Quick Start

### Prerequisites

Make sure you have the following packages installed:

- `hyprland` - Wayland compositor
- `waybar` - Status bar
- `rofi` - Application launcher
- `mako` - Notification daemon
- `foot` or `kitty` - Terminal emulator
- `zsh` - Shell
- `starship` - Prompt
- `vim` - Text editor
- `zathura` - PDF reader
- `mpv` - Media player

### Installation

1. **Install GNU Stow** (if not already installed):

   ```bash
   # Arch Linux
   sudo pacman -S stow

   # Ubuntu/Debian
   sudo apt install stow

   # Fedora
   sudo dnf install stow
   ```

2. **Backup your existing configs** (important!):

   ```bash
   cp -r ~/.config ~/.config.backup
   ```

3. **Clone the repository**:

   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

4. **Use Stow to manage symlinks**:

   ```bash
   # Install all configurations
   stow */

   # Or install specific configurations
   stow hypr waybar rofi mako foot kitty vim zsh

   # To remove configurations
   stow -D hypr waybar rofi
   ```

5. **Reload your session** or restart your display manager.

## ⚙️ Configuration Highlights

### Hyprland Window Manager

- Modern Wayland compositor with smooth animations
- Custom keybindings and workspace management
- Optimized for productivity and aesthetics

### Terminal Setup

- **Foot**: Lightweight and fast Wayland terminal
- **Kitty**: Feature-rich terminal with advanced capabilities
- **Zsh**: Enhanced shell with plugins and customizations
- **Starship**: Beautiful, cross-shell prompt

### Development Environment

- **Vim**: Configured for efficient text editing
- **Tmux**: Terminal multiplexer for session management
- Custom scripts in `bin/` for automation

### Multimedia & Utilities

- **MPV**: Minimalist media player with custom settings
- **Zathura**: Vim-like PDF reader
- **MangoHud**: Gaming performance overlay
- **Espanso**: Text expansion utility

## 🎨 Customization

### Themes and Appearance

- Check the `assets/` directory for wallpapers and themes
- Waybar themes and Rofi configurations can be found in their respective directories
- Font configurations are managed through `fontconfig/`

### Adding New Configurations

1. Create a new directory for your application
2. Add your config files
3. Update this README with installation instructions
4. Consider adding setup scripts in the `bin/` directory

## 📝 Notes

- All configurations are tested on Linux with Wayland
- Some configurations may require adjustment based on your specific distribution
- The `temp/` directory contains experimental configurations
- Regular updates and maintenance are recommended

## 🤝 Contributing

Feel free to:

- Submit issues for bugs or improvements
- Fork the repository for your own customizations
- Share interesting configurations or scripts

## 📄 License

This repository contains personal configuration files. Use at your own discretion and adapt to your needs.

---

_Last updated: December 2024_
