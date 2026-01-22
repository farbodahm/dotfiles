# Dotfiles

Personal configuration files for macOS and Linux.

## How It Works

This repository uses **symlinks** to manage dotfiles. Instead of copying files to your home directory, the install script creates symbolic links pointing back to this repository. This means:

- Editing `~/.zshrc` actually edits `dotfiles/zsh/.zshrc`
- Changes are automatically tracked by git
- You can easily sync configs across machines

```
~/.zshrc  →  ~/dotfiles/zsh/.zshrc
~/.config/nvim  →  ~/dotfiles/nvim
~/.config/espanso  →  ~/dotfiles/espanso
```

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script automatically detects your OS and:

| macOS | Linux |
|-------|-------|
| Installs Homebrew | Uses apt/dnf/pacman |
| Installs from Brewfile | Installs from packages/*.txt |
| Installs Oh My Zsh + plugins | Installs Oh My Zsh + plugins |
| Installs NVM | Installs NVM |
| Sets zsh as default shell | Sets zsh as default shell |
| Creates symlinks | Creates symlinks |

### Options

```bash
./install.sh              # Full installation
./install.sh --links-only # Only create symlinks
./install.sh --skip-packages  # Skip package installation
./install.sh --skip-deps      # Skip Oh-My-Zsh/NVM
./install.sh -h               # Show help
```

### Syncing changes between machines

After making changes on one machine:
```bash
cd ~/dotfiles
git add -A
git commit -m "Update zshrc aliases"
git push
```

On other machines, just pull:
```bash
cd ~/dotfiles
git pull
```

Changes apply immediately (symlinks point to the repo files).

## Adding Packages

### macOS (Homebrew)

Edit `Brewfile` for CLI tools:
```bash
brew "ripgrep"
brew "fzf"
```

Edit `Brewfile.macos` for GUI apps:
```bash
cask "visual-studio-code"
cask "docker"
```

Install:
```bash
brew bundle --file=~/dotfiles/Brewfile
brew bundle --file=~/dotfiles/Brewfile.macos
```

### Linux (apt/dnf/pacman)

Edit the appropriate file in `packages/`:

| Distro | File |
|--------|------|
| Ubuntu/Debian | `packages/apt.txt` |
| Fedora | `packages/dnf.txt` |
| Arch | `packages/pacman.txt` |

Format (one package per line, # for comments):
```bash
# Development tools
neovim
ripgrep
fzf

# Optional
# docker
```

Re-run install to add new packages:
```bash
./install.sh --skip-deps  # Skip oh-my-zsh, just install packages + links
```

## Adding New Config Files

### 1. Create a directory for the tool

```bash
mkdir ~/dotfiles/toolname
```

### 2. Copy your config file

```bash
cp ~/.toolconfig ~/dotfiles/toolname/.toolconfig
```

### 3. Update `install.sh`

Add a line in the `link_dotfiles()` function:

```bash
# For files in home directory
backup_and_link "$DOTFILES_DIR/toolname/.toolconfig" "$HOME/.toolconfig"

# For files in ~/.config
mkdir -p "$HOME/.config/toolname"
backup_and_link "$DOTFILES_DIR/toolname/config.yml" "$HOME/.config/toolname/config.yml"

# For entire directories
backup_and_link "$DOTFILES_DIR/toolname" "$HOME/.config/toolname"
```

### 4. Commit and push

```bash
git add -A
git commit -m "Add toolname config"
git push
```

## Platform Notes

### macOS
- Uses Homebrew for all packages
- GUI apps via casks in `Brewfile.macos`
- Homebrew at `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel)

### Linux
- Uses native package managers (apt, dnf, pacman)
- Package lists in `packages/` directory
- GUI apps: install via native package manager, Flatpak, or AppImage
- Supports Ubuntu, Debian, Fedora, Arch
