# mac-desktop-configure

Automated macOS setup script for a DevOps / developer workstation.

## What it installs

### Applications
- Brave, Obsidian, Colima, VSCode, Zed, iTerm2
- Microsoft Teams, Outlook, Fastmail
- Alfred 5, GIMP, Inkscape, OBS, pCloud, WhatsApp, VLC

### CLIs
- `kubectl`, `helm`, `az` (Azure CLI), `nvm`
- `eza`, `bat`, `ripgrep`, `fd`, `fzf`, `lazygit`

### Shell
- Oh My Zsh + Powerlevel10k
- Plugins: autosuggestions, syntax-highlighting, fzf-tab, history-substring-search
- LazyVim (Neovim config)

## Usage

```bash
chmod +x setup.sh
./setup.sh
```

After running:
1. Open iTerm2 and set font to **MesloLGS NF 13**
2. Run `nvim` once to let LazyVim bootstrap
3. Run `p10k configure` to customize your prompt
README
