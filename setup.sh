===============
# 1. HOMEBREW
# =============================================================================
section "Installing Homebrew"
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon
  if [[ "$(uname -m)" == "arm64" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  log "Homebrew installed"
else
  log "Homebrew already present, updating..."
  brew update
fi

# =============================================================================
# 2. GUI APPS (Casks)
# =============================================================================
section "Inst#!/bin/bash
# =============================================================================
# macOS Desktop Setup Script
# Installs apps, CLIs, configures iTerm2 + Zsh + Neovim
# =============================================================================

set -e

# ─── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
log()     { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
section() { echo -e "\n${BLUE}══════════════════════════════════════${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}══════════════════════════════════════${NC}"; }

# ==============================================================alling GUI Applications"

CASKS=(
  brave-browser         # Privacy-focused browser
  obsidian              # Note-taking / knowledge base
  colima                # Container runtime (Docker alternative)
  visual-studio-code    # Code editor
  zed                   # Fast code editor
  iterm2                # Terminal emulator
  microsoft-teams       # Team collaboration
  alfred                # Launcher (Alfred 5)
  gimp                  # Image editor
  inkscape              # Vector graphics editor
  obs                   # Screen recording / streaming
  pcloud                # Cloud storage
  whatsapp              # Messaging
  vlc                   # Media player
)

# Note: Microsoft Outlook (new) is available via mas or direct cask
# We'll install via cask
EXTRA_CASKS=(
  microsoft-outlook
)

for cask in "${CASKS[@]}"; do
  if brew list --cask "$cask" &>/dev/null; then
    warn "$cask already installed, skipping"
  else
    log "Installing $cask..."
    brew install --cask "$cask" || warn "Failed to install $cask"
  fi
done

# =============================================================================
# 3. CLI TOOLS
# =============================================================================
section "Installing CLI Tools"

FORMULAE=(
  kubectl               # Kubernetes CLI
  helm                  # Kubernetes package manager
  azure-cli             # Azure CLI (az)
  direnv                # Environment variable management
  nvm                   # Node Version Manager (via brew tap)
  neovim                # Neovim (for LazyVim)
  git                   # Git
  curl                  # HTTP client
  wget                  # File downloader
  eza                   # Modern ls replacement (replaces exa)
  zoxide                # Smarter cd
  fzf                   # Fuzzy finder (used by ctrl+r)
  bat                   # Better cat
  ripgrep               # Fast grep (needed by LazyVim/Telescope)
  fd                    # Fast find (needed by LazyVim)
  tree                  # Directory tree (classic)
  jq                    # JSON processor
  yq                    # YAML processor
)

for formula in "${FORMULAE[@]}"; do
  if brew list "$formula" &>/dev/null; then
    warn "$formula already installed, skipping"
  else
    log "Installing $formula..."
    brew install "$formula" || warn "Failed to install $formula"
  fi
done

# NVM post-install setup
log "Configuring nvm..."
mkdir -p ~/.nvm

# =============================================================================
# 4. OH MY ZSH
# =============================================================================
section "Installing Oh My Zsh"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  log "Oh My Zsh installed"
else
  warn "Oh My Zsh already installed"
fi

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ─── Powerlevel10k theme ───────────────────────────────────────────────────
section "Installing Powerlevel10k"
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  log "Powerlevel10k installed"
else
  warn "Powerlevel10k already present"
fi

# ─── Plugins ──────────────────────────────────────────────────────────────
section "Installing Zsh Plugins"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  log "zsh-autosuggestions installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  log "zsh-syntax-highlighting installed"
fi

# zsh-completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
  log "zsh-completions installed"
fi

# zsh-history-substring-search (better ctrl+r)
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-history-substring-search" ]; then
  git clone https://github.com/zsh-users/zsh-history-substring-search "$ZSH_CUSTOM/plugins/zsh-history-substring-search"
  log "zsh-history-substring-search installed"
fi

# fzf-tab (tab completion with fzf)
if [ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]; then
  git clone https://github.com/Aloxaf/fzf-tab "$ZSH_CUSTOM/plugins/fzf-tab"
  log "fzf-tab installed"
fi

# ─── Write .zshrc ─────────────────────────────────────────────────────────
section "Writing ~/.zshrc"

# Backup existing .zshrc
[ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"

cat > "$HOME/.zshrc" << 'ZSHRC'
# ── Powerlevel10k instant prompt (must stay at top) ─────────────────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Oh My Zsh ───────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  kubectl
  helm
  docker
  azure
  nvm
  npm
  fzf
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
  z
  sudo
  copyfile
  copypath
  extract
  aliases
  history
  macos
)

source $ZSH/oh-my-zsh.sh

# ── Homebrew ────────────────────────────────────────────────────────────────
if [[ "$(uname -m)" == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ── NVM ─────────────────────────────────────────────────────────────────────
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && source "$(brew --prefix)/opt/nvm/nvm.sh"
[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && source "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"

# ── FZF ─────────────────────────────────────────────────────────────────────
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# ctrl+r: enhanced history search
export FZF_CTRL_R_OPTS='--sort --exact'

# ── Zoxide (smart cd) ───────────────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── EZA (better ls) ─────────────────────────────────────────────────────────
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -la --icons --group-directories-first --git'
  alias la='eza -a --icons --group-directories-first'
  alias lt='eza --tree --icons --level=2'
  alias lt3='eza --tree --icons --level=3'
fi

# ── Aliases ─────────────────────────────────────────────────────────────────
alias vim='nvim'
alias vi='nvim'
alias k='kubectl'
alias kns='kubectl config set-context --current --namespace'
alias kctx='kubectl config use-context'
alias tf='terraform'
alias cdg='cd $(git rev-parse --show-toplevel)'

# ── Kubectl autocomplete ─────────────────────────────────────────────────────
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# ── Helm autocomplete ────────────────────────────────────────────────────────
[[ $commands[helm] ]] && source <(helm completion zsh)

# ── Azure CLI autocomplete ───────────────────────────────────────────────────
if [ -f "$(brew --prefix)/etc/bash_completion.d/az" ]; then
  source "$(brew --prefix)/etc/bash_completion.d/az"
fi

# ── History configuration ────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY

# ── History substring search bindings (arrow keys + ctrl+p/n) ───────────────
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down

# ── Powerlevel10k config ─────────────────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
ZSHRC

log "~/.zshrc written"

# ─── FZF shell integration ────────────────────────────────────────────────
log "Setting up fzf shell integration..."
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish 2>/dev/null || true

# =============================================================================
# 5. LAZYVIM (Neovim config)
# =============================================================================
section "Installing LazyVim"

if [ -d "$HOME/.config/nvim" ] && [ "$(ls -A $HOME/.config/nvim)" ]; then
  warn "Neovim config already exists, backing up..."
  mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d%H%M%S)"
fi

git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
rm -rf "$HOME/.config/nvim/.git"
log "LazyVim starter config installed at ~/.config/nvim"
log "Run 'nvim' once to let LazyVim install all plugins automatically"

# =============================================================================
# 6. NERD FONTS (required for icons in terminal / p10k / nvim)
# =============================================================================
section "Installing Nerd Fonts"

FONTS=(
  font-meslo-lg-nerd-font        # Recommended by Powerlevel10k
  font-jetbrains-mono-nerd-font  # Great for coding
  font-fira-code-nerd-font       # Popular dev font
)

brew tap homebrew/cask-fonts 2>/dev/null || true
for font in "${FONTS[@]}"; do
  brew install --cask "$font" 2>/dev/null || warn "Could not install $font"
done

# =============================================================================
# 7. iTerm2 CONFIGURATION
# =============================================================================
section "Configuring iTerm2"

ITERM_PREFS="$HOME/.config/iterm2"
mkdir -p "$ITERM_PREFS"

# Tell iTerm2 to use our custom preferences folder
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ITERM_PREFS"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

# Create a basic iTerm2 profile with good defaults
cat > "$ITERM_PREFS/com.googlecode.iterm2.plist" << 'ITERM_PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>New Bookmarks</key>
  <array>
    <dict>
      <key>Name</key><string>Default</string>
      <key>Guid</key><string>default-profile</string>
      <key>Normal Font</key><string>MesloLGSNerdFontComplete-Regular 13</string>
      <key>Non Ascii Font</key><string>MesloLGSNerdFontComplete-Regular 13</string>
      <key>Use Non-ASCII Font</key><true/>
      <key>Scrollback Lines</key><integer>10000</integer>
      <key>Option Key Sends</key><integer>2</integer>
      <key>Right Option Key Sends</key><integer>2</integer>
      <key>Background Color</key>
      <dict>
        <key>Red Component</key><real>0.11</real>
        <key>Green Component</key><real>0.12</real>
        <key>Blue Component</key><real>0.15</real>
        <key>Alpha Component</key><real>1</real>
        <key>Color Space</key><string>sRGB</string>
      </dict>
    </dict>
  </array>
</dict>
</plist>
ITERM_PLIST

log "iTerm2 preferences written to $ITERM_PREFS"
warn "Open iTerm2 → Preferences → Profiles → Text and set font to 'MesloLGS NF'"

# =============================================================================
# DONE
# =============================================================================
section "Setup Complete!"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "  1. Restart iTerm2 and set font: MesloLGS NF 13pt"
echo "  2. Run 'p10k configure' to set up your prompt"
echo "  3. Run 'nvim' once to let LazyVim install plugins"
echo "  4. Install Node.js: nvm install --lts"
echo "  5. Push repo: cd ~/dev/mac-desktop-configure && git push -u origin main"
echo ""
echo -e "${YELLOW}Note:${NC} Some apps (Fastmail, Outlook) may need manual download from App Store"
echo -e "${YELLOW}Note:${NC} Alfred 5 requires a Powerpack license for advanced features"
echo ""
