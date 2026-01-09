#!/bin/bash

# Dotfiles installation script
# This script creates symlinks from the dotfiles repo to your home directory

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

backup_and_link() {
    local src="$1"
    local dest="$2"

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    # Backup existing file/directory if it exists and is not a symlink
    if [[ -e "$dest" && ! -L "$dest" ]]; then
        mkdir -p "$BACKUP_DIR"
        log_warn "Backing up existing $dest to $BACKUP_DIR"
        mv "$dest" "$BACKUP_DIR/"
    elif [[ -L "$dest" ]]; then
        log_info "Removing existing symlink $dest"
        rm "$dest"
    fi

    # Create symlink
    ln -s "$src" "$dest"
    log_info "Linked $src -> $dest"
}

install_homebrew() {
    if ! command -v brew &> /dev/null; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        log_info "Homebrew already installed"
    fi
}

install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log_info "Oh My Zsh already installed"
    fi
}

install_zsh_plugins() {
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        log_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    # zsh-syntax-highlighting
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    # autoupdate plugin for oh-my-zsh
    if [[ ! -d "$ZSH_CUSTOM/plugins/autoupdate" ]]; then
        log_info "Installing autoupdate plugin..."
        git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins "$ZSH_CUSTOM/plugins/autoupdate"
    fi
}

install_packages() {
    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        log_info "Installing packages from Brewfile..."
        brew bundle --file="$DOTFILES_DIR/Brewfile"
    fi
}

link_dotfiles() {
    log_info "Linking dotfiles..."

    # Shell
    backup_and_link "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    backup_and_link "$DOTFILES_DIR/zsh/.zprofile" "$HOME/.zprofile"

    # Git
    backup_and_link "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

    # Wezterm
    backup_and_link "$DOTFILES_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

    # Neovim
    backup_and_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

    # Zed
    mkdir -p "$HOME/.config/zed"
    backup_and_link "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
    backup_and_link "$DOTFILES_DIR/zed/keymap.json" "$HOME/.config/zed/keymap.json"

    # GitHub CLI
    mkdir -p "$HOME/.config/gh"
    backup_and_link "$DOTFILES_DIR/gh/config.yml" "$HOME/.config/gh/config.yml"

    # htop
    mkdir -p "$HOME/.config/htop"
    backup_and_link "$DOTFILES_DIR/htop/htoprc" "$HOME/.config/htop/htoprc"
}

main() {
    echo ""
    echo "=================================="
    echo "  Dotfiles Installation Script"
    echo "=================================="
    echo ""

    # Parse arguments
    SKIP_PACKAGES=false
    SKIP_DEPS=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-packages)
                SKIP_PACKAGES=true
                shift
                ;;
            --skip-deps)
                SKIP_DEPS=true
                shift
                ;;
            --links-only)
                SKIP_PACKAGES=true
                SKIP_DEPS=true
                shift
                ;;
            -h|--help)
                echo "Usage: ./install.sh [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --skip-packages  Skip Brewfile package installation"
                echo "  --skip-deps      Skip Homebrew/Oh-My-Zsh installation"
                echo "  --links-only     Only create symlinks (skip all installations)"
                echo "  -h, --help       Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    if [[ "$SKIP_DEPS" == false ]]; then
        install_homebrew
        install_oh_my_zsh
        install_zsh_plugins
    fi

    if [[ "$SKIP_PACKAGES" == false ]]; then
        install_packages
    fi

    link_dotfiles

    echo ""
    log_info "Installation complete!"
    if [[ -d "$BACKUP_DIR" ]]; then
        log_info "Backups saved to: $BACKUP_DIR"
    fi
    echo ""
    log_info "Please restart your terminal or run: source ~/.zshrc"
    echo ""
}

main "$@"
