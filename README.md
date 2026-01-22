# Dotfiles

Personal configuration files for macOS and Linux using **symlinks** — editing `~/.zshrc` actually edits `dotfiles/zsh/.zshrc`, so changes are automatically tracked by git.

## Private Files (git-crypt)

Some files contain sensitive data (phone numbers, addresses) and are encrypted with [git-crypt](https://github.com/AGWA/git-crypt). They appear as binary on GitHub but decrypt automatically once unlocked.

**Encrypted files:** `espanso/match/private.yml`

### Unlocking on a new machine

```bash
# 1. Install git-crypt
brew install git-crypt        # macOS
sudo apt install git-crypt    # Ubuntu/Debian
sudo dnf install git-crypt    # Fedora
sudo pacman -S git-crypt      # Arch

# 2. Decode key from Bitwarden (stored as base64 in Secure Note)
echo "PASTE_BASE64_HERE" | base64 -d > ~/dotfiles-key

# 3. Unlock and cleanup
git-crypt unlock ~/dotfiles-key && rm ~/dotfiles-key
```

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
git-crypt unlock ~/dotfiles-key   # If you have encrypted files
./install.sh
```

The script detects your OS and installs packages (Homebrew/apt/dnf/pacman), Oh My Zsh, NVM, and creates symlinks.

```bash
./install.sh --links-only     # Only create symlinks
./install.sh --skip-packages  # Skip package installation
./install.sh --skip-deps      # Skip Oh-My-Zsh/NVM
```

### Syncing between machines

```bash
# Push changes
git add -A && git commit -m "Update config" && git push

# Pull on other machines (changes apply immediately via symlinks)
git pull
```

## Adding Packages

**macOS:** Edit `Brewfile` (CLI) or `Brewfile.macos` (GUI apps), then `brew bundle`

**Linux:** Edit `packages/apt.txt`, `packages/dnf.txt`, or `packages/pacman.txt` (one package per line)

## Adding New Config Files

1. Create directory: `mkdir ~/dotfiles/toolname`
2. Copy config: `cp ~/.toolconfig ~/dotfiles/toolname/`
3. Add to `install.sh` in `link_dotfiles()`:
   ```bash
   backup_and_link "$DOTFILES_DIR/toolname/.toolconfig" "$HOME/.toolconfig"
   ```
4. Commit and push
