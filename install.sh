#!/bin/bash

# Dotfiles installation script
# macOS: uses Homebrew
# Linux: uses native package managers (apt/dnf/pacman)

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

# Detect OS and package manager
OS="$(uname -s)"
case "$OS" in
    Darwin) OS="macos" ;;
    Linux)  OS="linux" ;;
    *)      echo "Unsupported OS: $OS"; exit 1 ;;
esac

# Detect Linux distro
DISTRO=""
PKG_MANAGER=""
if [[ "$OS" == "linux" ]]; then
    if command -v apt-get &> /dev/null; then
        DISTRO="debian"
        PKG_MANAGER="apt"
    elif command -v dnf &> /dev/null; then
        DISTRO="fedora"
        PKG_MANAGER="dnf"
    elif command -v pacman &> /dev/null; then
        DISTRO="arch"
        PKG_MANAGER="pacman"
    fi
fi

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

# ============ macOS Functions ============

install_homebrew() {
    if ! command -v brew &> /dev/null; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
    else
        log_info "Homebrew already installed"
    fi
}

install_macos_packages() {
    if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
        log_info "Installing packages from Brewfile..."
        brew bundle --file="$DOTFILES_DIR/Brewfile"
    fi
    if [[ -f "$DOTFILES_DIR/Brewfile.macos" ]]; then
        log_info "Installing macOS apps from Brewfile.macos..."
        brew bundle --file="$DOTFILES_DIR/Brewfile.macos"
    fi
}

# ============ Linux Functions ============

install_apt_packages() {
    log_info "Installing packages with apt..."
    sudo apt-get update

    if [[ -f "$DOTFILES_DIR/packages/apt.txt" ]]; then
        # Read packages from file, skip comments and empty lines
        while IFS= read -r pkg || [[ -n "$pkg" ]]; do
            [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
            sudo apt-get install -y "$pkg"
        done < "$DOTFILES_DIR/packages/apt.txt"
    else
        # Default packages
        sudo apt-get install -y git zsh curl neovim htop gh golang-go gnupg
    fi
}

install_dnf_packages() {
    log_info "Installing packages with dnf..."

    if [[ -f "$DOTFILES_DIR/packages/dnf.txt" ]]; then
        while IFS= read -r pkg || [[ -n "$pkg" ]]; do
            [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
            sudo dnf install -y "$pkg"
        done < "$DOTFILES_DIR/packages/dnf.txt"
    else
        # Default packages
        sudo dnf install -y git zsh curl neovim htop gh golang gnupg2
    fi
}

install_pacman_packages() {
    log_info "Installing packages with pacman..."

    if [[ -f "$DOTFILES_DIR/packages/pacman.txt" ]]; then
        while IFS= read -r pkg || [[ -n "$pkg" ]]; do
            [[ "$pkg" =~ ^#.*$ || -z "$pkg" ]] && continue
            sudo pacman -S --noconfirm "$pkg"
        done < "$DOTFILES_DIR/packages/pacman.txt"
    else
        # Default packages
        sudo pacman -Syu --noconfirm git zsh curl neovim htop github-cli go gnupg
    fi
}

install_linux_packages() {
    case "$PKG_MANAGER" in
        apt)    install_apt_packages ;;
        dnf)    install_dnf_packages ;;
        pacman) install_pacman_packages ;;
        *)      log_warn "Unknown package manager. Please install packages manually." ;;
    esac
}

# ============ Common Functions ============

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

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        log_info "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    if [[ ! -d "$ZSH_CUSTOM/plugins/autoupdate" ]]; then
        log_info "Installing autoupdate plugin..."
        git clone https://github.com/TamCore/autoupdate-oh-my-zsh-plugins "$ZSH_CUSTOM/plugins/autoupdate"
    fi
}

install_nvm() {
    if [[ ! -d "$HOME/.nvm" ]]; then
        log_info "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    else
        log_info "NVM already installed"
    fi
}

set_default_shell() {
    if [[ "$SHELL" != *"zsh"* ]]; then
        log_info "Setting zsh as default shell..."
        ZSH_PATH="$(which zsh)"
        if [[ "$OS" == "linux" ]]; then
            if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
                echo "$ZSH_PATH" | sudo tee -a /etc/shells
            fi
        fi
        chsh -s "$ZSH_PATH"
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

show_help() {
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --skip-packages  Skip package installation"
    echo "  --skip-deps      Skip Oh-My-Zsh/NVM installation"
    echo "  --links-only     Only create symlinks (skip all installations)"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Platform: $OS"
    if [[ "$OS" == "linux" ]]; then
        echo "Distro:   $DISTRO"
        echo "Package manager: $PKG_MANAGER"
    fi
}

main() {
    echo ""
    echo "=================================="
    echo "  Dotfiles Installation Script"
    echo "=================================="
    echo ""
    log_info "Detected OS: $OS"
    if [[ "$OS" == "linux" ]]; then
        log_info "Detected distro: $DISTRO ($PKG_MANAGER)"
    fi
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
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Install packages
    if [[ "$SKIP_PACKAGES" == false ]]; then
        if [[ "$OS" == "macos" ]]; then
            install_homebrew
            install_macos_packages
        else
            install_linux_packages
        fi
    fi

    # Install dependencies (oh-my-zsh, plugins, nvm)
    if [[ "$SKIP_DEPS" == false ]]; then
        install_oh_my_zsh
        install_zsh_plugins
        install_nvm
        set_default_shell
    fi

    # Link dotfiles
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
