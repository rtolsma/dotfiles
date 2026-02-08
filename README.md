# Ryan's Mac Setup -- AI Agent Bootstrapping Guide

This document contains everything needed to replicate Ryan's Mac environment on a fresh Apple Silicon Mac. It is written so that an AI coding agent (e.g. Claude Code) can read it and execute the setup steps programmatically.

**Source machine:** Apple Silicon (M2 Max, arm64), macOS Tahoe 26.x, default shell zsh.

---

## Quick Start

```bash
# Clone this repo
git clone https://github.com/rtolsma/dotfiles.git ~/Git/dotfiles
cd ~/Git/dotfiles

# Run the setup script (idempotent -- safe to re-run)
bash setup.sh
```

The script handles: Xcode CLT, Homebrew, all packages (Brewfile), shell configs, version managers, editor configs, fonts, iTerm2/Alfred preferences, macOS defaults, dock setup, login items, wallpaper, and editor extensions.

After the script completes, follow the manual steps printed at the end (license activations, account sign-ins, privacy permissions).

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Homebrew + Packages](#2-homebrew--packages)
3. [Shell Configuration](#3-shell-configuration)
4. [Git Configuration](#4-git-configuration)
5. [Version Managers (asdf, rye, cargo, bun)](#5-version-managers)
6. [Window Management (yabai + skhd + Rectangle)](#6-window-management-yabai--skhd--rectangle)
7. [Keyboard (Karabiner-Elements)](#7-keyboard-karabiner-elements)
8. [Hammerspoon](#8-hammerspoon)
9. [Alfred 5](#9-alfred-5)
10. [Wispr Flow](#10-wispr-flow)
11. [Menubar & Utility Apps](#11-menubar--utility-apps)
12. [Vim Configuration](#12-vim-configuration)
13. [Editor Setup (Cursor + VS Code)](#13-editor-setup)
14. [Claude Code](#14-claude-code)
15. [macOS System Preferences](#15-macos-system-preferences)
16. [Fonts](#16-fonts)
17. [Dock & Login Items](#17-dock--login-items)
18. [Browser Extensions](#18-browser-extensions)
19. [Secrets & API Keys](#19-secrets--api-keys)
20. [Services & Launch Agents](#20-services--launch-agents)
21. [SSH Keys](#21-ssh-keys)
22. [Manual Post-Setup Checklist](#22-manual-post-setup-checklist)

---

## 1. Prerequisites

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

---

## 2. Homebrew + Packages

All packages are declared in `Brewfile`. Install everything at once:

```bash
brew bundle --file=Brewfile --no-lock
```

### What's in the Brewfile

**Taps (10):** gromgit/fuse, hashicorp/tap, keith/formulae, koekeishiya/formulae, microsoft/mssql-release, ngrok/ngrok, sheeki03/tap, supabase/tap, tw93/tap, withgraphite/tap

**Formulae (~80):** Core dev tools (git, gh, jj, graphite, ripgrep, jq, etc.), languages (go, node, deno, python 3.10-3.14, openjdk), package managers (pnpm, pipx, poetry, uv, maven, mas), infrastructure (awscli, azure-cli, terraform, docker, supabase), databases (postgresql@16, dbmate, mssql tools), AI/ML (openai-whisper, pytorch, gemini-cli, peekaboo, sag, summarize), media (ffmpeg, imagemagick, pandoc), window management (yabai, skhd, dockutil), and more.

**Casks (~50):** Nearly all GUI apps are installed via Homebrew casks, including: dev tools (cursor, visual-studio-code, ghostty, iterm2, orbstack, docker-desktop), system tools (hammerspoon, karabiner-elements, rectangle, spaceid, alfred, cleanshot, flux), browsers (arc, google-chrome), communication (slack, discord, signal, whatsapp, zoom), productivity (notion, superhuman, linear-linear, anki), AI (chatgpt, claude, ollama), media (spotify, vlc), security (1password, bitwarden, tailscale), and more.

### Start services

```bash
brew services start postgresql@16
skhd --start-service
yabai --start-service
```

---

## 3. Shell Configuration

**Default shell:** `/bin/zsh`

Files managed by this repo (symlinked to `~` by setup.sh):

| File | Purpose |
|------|---------|
| `.zshenv` | Cargo env (sourced before .zprofile) |
| `.zprofile` | Brew, asdf completions, pipx PATH, OrbStack |
| `.zshrc` | History, prompt, aliases, conda, paths, secrets |

Key aliases: `c` = claude, `j` = just, `gg` = cd to ~/Git/, `r` = ranger, `codex` / `gemini` with permissive flags.

Secrets are loaded from `~/.secrets` (see section 19).

---

## 4. Git Configuration

### ~/.gitconfig

- User: Ryan Tolsma <1tolsmar@gmail.com>
- Aliases: co, s, ri, rc, pf, b, l
- fetch.prune, submodule.recurse, init.defaultBranch=main, Git LFS

### ~/.config/git/ignore

```
**/.claude/settings.local.json
```

### ~/.config/gh/config.yml

- Protocol: HTTPS, aliases: `co = pr checkout`

### ~/.config/jj/config.toml

- Jujutsu VCS user config

---

## 5. Version Managers

| Tool | Versions | Install method |
|------|----------|---------------|
| asdf | ruby 3.2.2, nodejs 22.12.0 | git clone v0.14.0 |
| Rust | 1.72.1 | rustup |
| Rye | latest | curl installer |
| Bun | latest | curl installer |
| Conda | via Anaconda cask | lazy-loaded in .zshrc |
| uv | via brew | |
| Google Cloud SDK | latest | manual install |

### ~/.tool-versions

```
ruby 3.2.2
nodejs 22.12.0
```

### Global npm packages

```bash
npm install -g @openai/codex cursor-tools happy-coder pnpm pyright @anthropic-ai/claude-code
```

---

## 6. Window Management (yabai + skhd + Rectangle)

### ~/.yabairc

BSP tiling layout, mouse follows focus, inactive window opacity 90%, no gaps/padding, float system preferences windows. Signals trigger `~/.yabai-focus.sh` on space/display change.

### ~/.skhdrc

| Shortcut | Action |
|----------|--------|
| Alt+H/L | Switch displays |
| Alt+J/K | Focus west/east window |
| Alt+Shift+J/K/N/P | Swap/move windows |
| Alt+Ctrl+J/K/N/P | Set insertion point |
| Alt+F | Focus recent window |
| Alt+Shift+1-0 | Move window to space 1-10 |
| Alt+Shift+X/Y | Mirror display |
| Alt+Shift+U | Balance windows |
| Alt+E | Toggle BSP layout |
| Alt+W | Toggle stack layout |
| Alt+I/O | Cycle stack windows |

### yabai scripting addition

```bash
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
```

### Rectangle

Supplementary window snapping. Configured via defaults: alternate shortcuts, launch on login.

---

## 7. Keyboard (Karabiner-Elements)

### ~/.config/karabiner/karabiner.json

Caps Lock is remapped to Left Option globally and per-device (vendor_id 1133, product_id 45913).

---

## 8. Hammerspoon

### ~/.hammerspoon/init.lua

Loads **stackline** (yabai window stack indicator) with yabai path at `/opt/homebrew/bin/yabai`.

```bash
git clone https://github.com/AdamWagworski/stackline.git ~/.hammerspoon/stackline
```

---

## 9. Alfred 5

Primary launcher (replaces Spotlight). **Powerpack license: `YOUR_ALFRED_LICENSE`**.

Alfred preferences are stored in `config/alfred/` and deployed by setup.sh.

### Key settings to verify after install

| Setting | Value |
|---------|-------|
| Hotkey | **Ctrl+D** |
| Clipboard History hotkey | **Ctrl+C** |
| Theme | Modern Dark |
| Terminal integration | **iTerm** |

---

## 10. Wispr Flow

Voice-to-text dictation tool. **Pro yearly subscription** (renewal: 2026-12-07).

Install via `brew install --cask wispr-flow`. Sign in with Google (1tolsmar@gmail.com).

### Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| Cmd (hold) | Push-to-talk |
| Option+Cmd | Push-on, pop-off (POPO) |
| Ctrl+Cmd | Lens |
| Shift+Cmd+Tab | Paste last text |

---

## 11. Menubar & Utility Apps

All configured via `defaults write` in setup.sh:

| App | Key settings |
|-----|-------------|
| SpaceId | Launch on login, underline active monitor |
| Rectangle | Alternate shortcuts, launch on login |
| Flux | Denver area (39.62, -104.87), 2300K late / 6100K night |
| CleanShot X | No desktop icons, license: `YOUR_CLEANSHOT_LICENSE` |
| MeetingBar | macOS Calendar, Google Meet default |
| Tailscale | Sign in to sync config |
| 1Password | Sign in to vault, enable browser extensions |

---

## 12. Vim Configuration

### ~/.vimrc

- Theme: solarized8_flat (light background)
- Default: tabs; C++/JS: 2-space; Python/Markdown: 4-space
- Key remaps: jj=Esc, ;=:, H/L=tabs, J/K=8-line jumps, Space=leader

Color scheme installed by setup.sh from [vim-solarized8](https://github.com/lifepillar/vim-solarized8).

---

## 13. Editor Setup

### Cursor (primary)

Settings, keybindings, and MCP config are stored in `config/cursor/` and deployed by setup.sh.

**51 extensions** installed automatically (see setup.sh step 11).

Key settings: vim mode with .vimrc, partial accepts, Playwright reuse browser, CodeRabbit prompt mode.

### VS Code (secondary)

Settings stored in `config/vscode/settings.json`. **20 extensions** installed automatically.

Key difference from Cursor: `editor.formatOnSave: true`, GitHub Copilot instead of Cursor AI.

---

## 14. Claude Code

### ~/.claude/settings.json

Plugins: pg@aiguide, playwright, document-skills, frontend-design, ralph-wiggum, pr-review-toolkit, ralph-loop.

```bash
npm install -g @anthropic-ai/claude-code
```

---

## 15. macOS System Preferences

All set via `defaults write` in setup.sh. Key non-default settings:

### Keyboard & Input
- Fast key repeat: InitialKeyRepeat=15, KeyRepeat=2
- Mouse/trackpad tracking: 2.5 speed
- Tap-to-click: OFF, two-finger right-click: ON

### Text Corrections (all disabled)
- Auto-correct, auto-capitalize, smart quotes, smart dashes, auto-period: OFF

### Appearance
- Light mode, no window animations, instant resize
- UI sounds: OFF, reduce motion: ON

### Dock
- Auto-hide: ON, tile size: 56, no magnification, no MRU spaces

### Finder
- Show hidden files, list view default, no empty trash warning

### Window Manager
- Stage Manager: OFF, click desktop: OFF, no tiled margins

### Keyboard Shortcuts
- Ctrl+1-0: switch desktops 1-10
- Built-in screenshot shortcuts: disabled (CleanShot X)
- Mission Control shortcuts: disabled (yabai/skhd)

### Hot Corners
- All disabled

### Energy
- Battery: 3 min display, 1 min sleep
- AC: 10 min display, 1 min sleep

---

## 16. Fonts

**TWK Lausanne** — full variable weight family (50-1000 in 50-step increments, each with italic variant). 40 .otf files stored in `fonts/` and installed to `~/Library/Fonts/` by setup.sh.

---

## 17. Dock & Login Items

### Dock (automated via dockutil)

Left to right: Arc, Messages, Superhuman, Slack, Cursor, iTerm, Notion, Spotify, Calendar, System Settings, Reminders, ChatGPT.

### Login Items (automated via osascript)

Dropbox, MeetingBar, Notion, SpaceId, Superhuman, CleanShot X, OrbStack, Alfred 5, Hammerspoon, Flux, Graphite, 1Password, Tailscale.

### Wallpaper

`wallpapers/Riverside by ArseniXC.heic` — set automatically by setup.sh.

---

## 18. Browser Extensions

### Arc / Chrome

- Vimium
- Toucan
- Adblock
- Bitwarden

---

## 19. Secrets & API Keys

**DO NOT commit real keys.** A template is provided at `.secrets.template`.

On the new machine:
```bash
cp .secrets.template ~/.secrets
chmod 600 ~/.secrets
# Edit ~/.secrets and fill in your values
```

The `.zshrc` automatically sources `~/.secrets` if it exists.

### Other credentials to set up

| Service | Command |
|---------|---------|
| GitHub CLI | `gh auth login` |
| Google Cloud | `gcloud auth login` |
| Modal | edit `~/.modal.toml` |
| Graphite | `gt auth` |
| rclone | `rclone config` (Google Drive OAuth) |

---

## 20. Services & Launch Agents

| Service | How to start |
|---------|-------------|
| PostgreSQL 16 | `brew services start postgresql@16` |
| yabai | `yabai --start-service` |
| skhd | `skhd --start-service` |
| Hammerspoon | Launch from Applications (login item) |
| Karabiner-Elements | Launch from Applications (login item) |
| SpaceId | Launch from Applications (login item) |
| Rectangle | Launch from Applications (login item) |
| Alfred 5 | Launch from Applications (login item) |
| Wispr Flow | Launch from Applications (login item) |
| CleanShot X | Launch from Applications (login item) |
| MeetingBar | Launch from Applications (login item) |
| Flux | Launch from Applications (login item) |
| 1Password | Launch from Applications (login item) |
| Tailscale | Launch from Applications (login item) |

---

## 21. SSH Keys

```bash
ssh-keygen -t ed25519 -C "1tolsmar@gmail.com"
cat ~/.ssh/id_ed25519.pub | pbcopy
# Add to GitHub: https://github.com/settings/keys
```

SSH config includes OrbStack integration (`Include ~/.orbstack/ssh/config`).

---

## 22. Manual Post-Setup Checklist

These cannot be automated and must be done after running `setup.sh`:

- [ ] Create 12 desktops in Mission Control
- [ ] Activate Alfred Powerpack license (`YOUR_ALFRED_LICENSE`)
- [ ] Set Alfred hotkey to Ctrl+D, clipboard history to Ctrl+C, terminal to iTerm
- [ ] Activate CleanShot X license (`YOUR_CLEANSHOT_LICENSE`)
- [ ] Sign in to Wispr Flow with Google, verify keyboard shortcuts
- [ ] Grant **accessibility** permissions: skhd, yabai, Hammerspoon, Alfred, Rectangle, iTerm2
- [ ] Grant **screen recording** permissions: Chrome, iTerm2, Slack, Discord, Teams, Zoom, Arc, CleanShot X
- [ ] Sign in to: 1Password, Dropbox, Google Drive, OneDrive, Slack, Discord, Notion, Superhuman, Linear, Tailscale
- [ ] Run `gh auth login`, `gcloud auth login`, `gt auth`
- [ ] Fill in `~/.secrets` with API keys
- [ ] Generate SSH key and add to GitHub
- [ ] Install browser extensions: Vimium, Toucan, Adblock, Bitwarden
- [ ] Configure yabai scripting addition (see section 6)

---

## Repo Structure

```
dotfiles/
├── setup.sh                    # Main bootstrap script (idempotent)
├── Brewfile                    # Homebrew packages & casks
├── README.md                   # This file
├── .secrets.template           # API key template
├── .zshrc / .zprofile / .zshenv  # Shell configs
├── .gitconfig                  # Git config
├── .vimrc                      # Vim config
├── .yabairc / .skhdrc / .yabai-focus.sh  # Window management
├── .tool-versions              # asdf versions
├── .python-version             # Python version
├── config/
│   ├── alfred/                 # Alfred preferences bundle
│   ├── claude/settings.json    # Claude Code plugins
│   ├── cursor/                 # Cursor settings, keybindings, MCP
│   ├── gh/config.yml           # GitHub CLI
│   ├── git/ignore              # Global gitignore
│   ├── iterm2/                 # iTerm2 preferences plist
│   ├── jj/config.toml          # Jujutsu VCS
│   ├── karabiner/karabiner.json  # Keyboard remapping
│   ├── ssh/config              # SSH config
│   └── vscode/settings.json   # VS Code settings
├── fonts/                      # TWK Lausanne (40 .otf files)
├── wallpapers/                 # Desktop wallpaper
├── .vim/colors/                # Vim color schemes
├── .zsh/                       # Zsh completions
└── .hammerspoon/               # Hammerspoon + stackline
```
