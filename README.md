# Ryan's Mac Setup -- AI Agent Bootstrapping Guide

This document contains everything needed to replicate Ryan's Mac environment on a fresh Apple Silicon Mac. It is written so that an AI coding agent (e.g. Claude Code) can read it and execute the setup steps programmatically.

**Source machine:** Apple Silicon (arm64), macOS Tahoe 26.x, default shell zsh.

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
16. [Applications (non-Homebrew)](#16-applications-non-homebrew)
17. [Browser Extensions](#17-browser-extensions)
18. [Secrets & API Keys](#18-secrets--api-keys)
19. [Services & Launch Agents](#19-services--launch-agents)
20. [SSH Keys](#20-ssh-keys)

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

### Taps

```bash
brew tap gromgit/fuse
brew tap hashicorp/tap
brew tap homebrew/services
brew tap keith/formulae
brew tap koekeishiya/formulae
brew tap microsoft/mssql-release
brew tap ngrok/ngrok
brew tap popcorn-official/popcorn-desktop
brew tap steipete/tap
brew tap supabase/tap
brew tap tw93/tap
brew tap withgraphite/tap
```

### Formulae (CLI tools & libraries)

Use `brew bundle --file=Brewfile` to install everything at once (see `Brewfile` in this repo), or install individually:

**Core dev tools:**
```bash
brew install git git-lfs gh jj graphite just lefthook pre-commit ripgrep shellcheck jq curl wget tree htop ncdu ranger
```

**Languages & runtimes:**
```bash
brew install deno go node openjdk openjdk@21 python@3.12 python@3.13 python@3.14 llvm@20
```

**Package managers:**
```bash
brew install pnpm pipx poetry uv maven
```

**Infrastructure & cloud:**
```bash
brew install awscli azure-cli terraform packer supabase act actionlint docker
brew install postgresql@16
brew install nmap openconnect rclone
```

**AI / ML:**
```bash
brew install openai-whisper pytorch gemini-cli
```

**Media:**
```bash
brew install ffmpeg imagemagick tesseract pandoc
```

**Window management:**
```bash
brew install yabai skhd
```

**Other notable:**
```bash
brew install ast-grep dbmate himalaya signal-cli semgrep trivy swagger-codegen openapi-generator mole
```

### Casks (GUI apps)

```bash
brew install --cask anaconda basictex cursor docker docker-desktop fuse ghostty hammerspoon iterm2 karabiner-elements macfuse ngrok orbstack spaceid spotify upscayl vlc
```

### Start services

```bash
brew services start postgresql@16
skhd --start-service
yabai --start-service
```

---

## 3. Shell Configuration

**Default shell:** `/bin/zsh`

### ~/.zshenv

```bash
. "$HOME/.cargo/env"
```

### ~/.zprofile

```bash
# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

fpath=(${ASDF_DIR}/completions $fpath) # Asdf completions
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath) # just completions
autoload -Uz compinit && compinit

# Created by `pipx` on 2023-09-03 09:28:06
export PATH="$PATH:/Users/ryan/.local/bin"

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
```

### ~/.zshrc

```bash
export HISTFILESIZE=100000000
export HISTSIZE=100000000
export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE

setopt INC_APPEND_HISTORY
setopt HIST_FIND_NO_DUPS

fpath=(~/.zsh $fpath)

# Git Prompt Completion
source ~/.git-prompt.sh
setopt PROMPT_SUBST ; PS1='[%n@%m %c$(__git_ps1 " (%s)")]\$ '

# Aliases
alias cd..="cd .."
alias up="cd .."
alias gg="cd /Users/ryan/Git/"
alias r="ranger"
alias rr="rye run"

# >>> conda initialize (lazy-loaded) >>>
conda() {
    unfunction conda
    eval "$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    conda "$@"
}
# <<< conda initialize <<<

# Homebrew
eval "$(brew shellenv)"
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath)

aug() { cd ~/Git/august${1:+$1}; }
cs() { cd ~/Git/august${1:+$1}/caesar; }

rcm() {
	cd ~/Git/august/apps/rcm-portal;
}
am() {
	git add --all;
	git commit --amend;
}
ybr() {
	yabai --stop-service
	yabai --start-service
}

alias j="just"
alias c="claude --dangerously-skip-permissions"
alias codex="codex -a never -s danger-full-access"
alias gemini="gemini --yolo"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Created by `pipx` on 2023-09-03 09:28:06
export PATH="$PATH:/Users/ryan/.local/bin"

# NOTE: API keys are stored separately -- see "Secrets & API Keys" section
# export OPENAI_API_KEY='...'
# export GEMINI_API_KEY='...'
# export OAGI_API_KEY='...'
# export OAGI_BASE_URL=https://api.agiopen.org

# Browser-Use
export ANONYMIZED_TELEMETRY=false

unset DYLD_LIBRARY_PATH

# Path finalizers
# Asdf
. "$HOME/.asdf/asdf.sh"
# Rye
. "$HOME/.rye/env"
# Cargo
. "$HOME/.cargo/env"

# Google Cloud SDK
if [ -f '/Users/ryan/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ryan/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/ryan/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ryan/google-cloud-sdk/completion.zsh.inc'; fi

# bun completions
[ -s "/Users/ryan/.bun/_bun" ] && source "/Users/ryan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
```

### ~/.git-prompt.sh

This is the standard git prompt script from the git project. Download it:
```bash
curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
```

---

## 4. Git Configuration

### ~/.gitconfig

```ini
[user]
	name = Ryan Tolsma
	email = 1tolsmar@gmail.com

[alias]
	co = checkout
	s = status
	ri = rebase -i
	rc = rebase --continue
	pf = push --force-with-lease
	b = branch
	l = log

[fetch]
	prune = true
[submodule]
	recurse = true

[http]
	postBuffer = 1572864000
[init]
	defaultBranch = main
[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true
```

### ~/.config/git/ignore

```
**/.claude/settings.local.json
```

### ~/.config/gh/config.yml

```yaml
git_protocol: https
editor:
prompt: enabled
pager:
aliases:
    co: pr checkout
http_unix_socket:
browser:
version: "1"
```

### ~/.config/jj/config.toml (Jujutsu VCS)

```toml
#:schema https://docs.jj-vcs.dev/latest/config-schema.json

[user]
name = "rtolsma"
email = "1tolsmar@gmail.com"
```

---

## 5. Version Managers

### asdf

```bash
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
# Add to shell (already in .zshrc): . "$HOME/.asdf/asdf.sh"

asdf plugin add ruby
asdf plugin add nodejs

asdf install ruby 3.2.2
asdf install nodejs 22.12.0

asdf global ruby 3.2.2
asdf global nodejs 22.12.0
```

### ~/.tool-versions

```
ruby 3.2.2
nodejs 22.12.0
```

### ~/.python-version

```
3.12.5
```

### Rye (Python)

```bash
curl -sSf https://rye.astral.sh/get | bash
# Adds: . "$HOME/.rye/env" (already in .zshrc)
```

### Rust / Cargo

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# Adds: . "$HOME/.cargo/env" (already in .zshrc/.zshenv)
# Installed: rustc 1.72.1
```

### Bun

```bash
curl -fsSL https://bun.sh/install | bash
# Adds BUN_INSTALL and completions (already in .zshrc)
```

### Conda (via Anaconda cask)

Lazy-loaded in .zshrc. Installed via `brew install --cask anaconda`.

### uv (Python)

```bash
# Already installed via brew: brew install uv
```

### Global npm packages

```bash
npm install -g @openai/codex cursor-tools happy-coder pnpm pyright
```

### Google Cloud SDK

```bash
curl https://sdk.cloud.google.com | bash
# Or download from https://cloud.google.com/sdk/docs/install
# Adds path.zsh.inc and completion.zsh.inc (already in .zshrc)
```

---

## 6. Window Management (yabai + skhd + Rectangle)

### ~/.yabairc

```bash
#!/usr/bin/env sh

yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
sudo yabai --load-sa

# bar settings
yabai -m config top_padding 0

# global settings
yabai -m config mouse_follows_focus          on
yabai -m config focus_follows_mouse          off

yabai -m config window_placement             second_child
yabai -m config window_topmost               off

yabai -m config window_opacity               off
yabai -m config window_opacity_duration      0.0
yabai -m config window_shadow                on

yabai -m config active_window_opacity        1.0
yabai -m config normal_window_opacity        0.90
yabai -m config split_ratio                  0.50
yabai -m config auto_balance                 off

# Mouse support
yabai -m config mouse_modifier               alt
yabai -m config mouse_action1                move
yabai -m config mouse_action2                resize

# general space settings
yabai -m config layout                       bsp
yabai -m config bottom_padding               -5
yabai -m config left_padding                 0
yabai -m config right_padding                0
yabai -m config window_gap                   0

# float system preferences
yabai -m rule --add app='^System Information$' manage=off
yabai -m rule --add app='^System Preferences$' manage=off
yabai -m rule --add title='Preferences$' manage=off
yabai -m rule --add title='Settings$' manage=off

# focus window after active space changes
yabai -m signal --add event=space_changed action="~/.yabai-focus.sh "
yabai -m signal --add event=display_changed action="~/.yabai-focus.sh"
```

### ~/.yabai-focus.sh

```bash
#!/bin/bash
set +e

CURR_DISPLAY=$(yabai -m query --displays --display | jq '.id' | head -n 1)
TARGET_DISPLAY=${1:-$CURR_DISPLAY}

VISIBLE_WINDOW_ID=$(yabai -m query --windows --display $TARGET_DISPLAY  | jq 'sort_by(.stack_index) | .[] | select(.["is-visible"] == true and .["is-hidden"] == false and .["is-minimized"] == false and .["subrole"] == "AXStandardWindow" and .["layer"] == "normal") | .id' | head -n 1)

if [ ! -z "$VISIBLE_WINDOW_ID" ]; then
    yabai -m window --focus $VISIBLE_WINDOW_ID
else
    echo "No visible window found on display $TARGET_DISPLAY"
fi
```

Make executable: `chmod +x ~/.yabai-focus.sh`

### ~/.skhdrc

```bash
# change focus on displays...
alt - h : yabai -m display --focus 2 || $( yabai -m query --displays --display | jq '.id' | ~/.yabai-focus.sh )
alt - l : yabai -m display --focus 1 || $( yabai -m query --displays --display | jq '.id' | ~/.yabai-focus.sh )

# change focus within display
alt - j : yabai -m window --focus west
alt - k : yabai -m window --focus east

# shift window in current workspace
alt + shift - j : yabai -m window --swap west || $(yabai -m window --display west; yabai -m display --focus west)
alt + shift - k : yabai -m window --swap east || $(yabai -m window --display east; yabai -m display --focus east)
alt + shift - n : yabai -m window --swap south || $(yabai -m window --display south; yabai -m display --focus south)
alt + shift - p : yabai -m window --swap north || $(yabai -m window --display north; yabai -m display --focus north)

# set insertion point in focused container
alt + ctrl - j : yabai -m window --insert west
alt + ctrl - n : yabai -m window --insert south
alt + ctrl - p : yabai -m window --insert north
alt + ctrl - k : yabai -m window --insert east

# go back to previous workspace
alt - f : yabai -m window --focus recent

# move focused window to previous workspace
alt + shift - f : yabai -m window --space recent; \

# move focused window to workspace N
alt + shift - 1 : yabai -m window --space 1
alt + shift - 2 : yabai -m window --space 2
alt + shift - 3 : yabai -m window --space 3
alt + shift - 4 : yabai -m window --space 4
alt + shift - 5 : yabai -m window --space 5
alt + shift - 6 : yabai -m window --space 6
alt + shift - 7 : yabai -m window --space 7
alt + shift - 8 : yabai -m window --space 8
alt + shift - 9 : yabai -m window --space 9
alt + shift - 0 : yabai -m window --space 10

# mirror tree y-axis
alt + shift - y : yabai -m space --mirror y-axis

# mirror tree x-axis
alt + shift - x: yabai -m space --mirror x-axis

# balance size of windows
alt + shift - u : yabai -m space --balance

# change layout of desktop
alt - e : yabai -m space --layout bsp || yabai -m space --mirror y-axis
alt - w : yabai -m space --layout stack

# cycle through stack windows
alt - i : yabai -m window --focus stack.next || yabai -m window --focus south
alt - o : yabai -m window --focus stack.prev || yabai -m window --focus north
```

### yabai scripting addition (required)

```bash
# Allow yabai to load the scripting addition without password
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai
```

### Rectangle (supplementary window management)

Rectangle provides keyboard-driven window snapping alongside yabai. Install via direct download or App Store.

Settings to configure after install:
```bash
# Enable alternate shortcuts mode and launch on login
defaults write com.knollsoft.Rectangle alternateDefaultShortcuts -bool true
defaults write com.knollsoft.Rectangle launchOnLogin -bool true
defaults write com.knollsoft.Rectangle subsequentExecutionMode -int 1

# Disable auto-updates (manual preferred)
defaults write com.knollsoft.Rectangle SUEnableAutomaticChecks -bool false
```

---

## 7. Keyboard (Karabiner-Elements)

### ~/.config/karabiner/karabiner.json

Caps Lock is remapped to Left Option globally:

```json
{
    "profiles": [
        {
            "devices": [
                {
                    "identifiers": {
                        "is_keyboard": true,
                        "is_pointing_device": true,
                        "product_id": 45913,
                        "vendor_id": 1133
                    },
                    "ignore": false,
                    "simple_modifications": [
                        {
                            "from": { "key_code": "caps_lock" },
                            "to": [{ "key_code": "left_option" }]
                        }
                    ]
                }
            ],
            "name": "Default profile",
            "selected": true,
            "simple_modifications": [
                {
                    "from": { "key_code": "caps_lock" },
                    "to": [{ "key_code": "left_option" }]
                }
            ],
            "virtual_hid_keyboard": {
                "country_code": 0,
                "keyboard_type_v2": "ansi"
            }
        }
    ]
}
```

---

## 8. Hammerspoon

### ~/.hammerspoon/init.lua

```lua
require("hs.ipc")
stackline = require "stackline"
stackline:init({
	paths = {
		yabai = "/opt/homebrew/bin/yabai"
	}
})
```

**stackline** is a yabai companion that shows visual stack indicators. Clone it into the Hammerspoon config:

```bash
git clone https://github.com/AdamWagworski/stackline.git ~/.hammerspoon/stackline
```

---

## 9. Alfred 5

Alfred is the primary launcher (replaces Spotlight). **Powerpack license required** (licensed under key `T0WDJ9C6DC`).

Install: Download from [alfredapp.com](https://www.alfredapp.com/).

### Key settings to configure

| Setting | Value |
|---------|-------|
| Hotkey | **Ctrl+D** (opens Alfred) |
| Clipboard History hotkey | **Ctrl+C** |
| Theme | Modern Dark |
| Terminal integration | **iTerm** (not Terminal.app) |
| Default meeting service | Google Meet |
| Clipboard history | Enabled (3s persistence) |
| Show contacts | Disabled |
| Show documents | Enabled |
| Show folders | Enabled |

### iTerm integration

Alfred is configured to send terminal commands to iTerm instead of Terminal.app. This is set in:
**Alfred Preferences > Features > Terminal > Application: Custom** with an AppleScript that targets iTerm.

### Bookmarks / web searches

Default web searches are configured with quick-access URLs for Wikipedia, YouTube, Twitter, Apple, BBC News, and Alfred help.

### Alfred preferences location

All Alfred config lives in:
```
~/Library/Application Support/Alfred/Alfred.alfredpreferences/
```

After installing Alfred on the new machine:
1. Activate Powerpack license
2. Set hotkey to Ctrl+D
3. Set clipboard history hotkey to Ctrl+C
4. Change terminal to iTerm (Preferences > Features > Terminal)
5. Set theme to Modern Dark
6. Enable clipboard history

---

## 10. Wispr Flow

Wispr Flow is a voice-to-text dictation tool. **Pro yearly subscription** (renewal: 2026-12-07).

Install: Download from [wisprflow.com](https://www.wisprflow.com/). Sign in with Google (1tolsmar@gmail.com).

### Key settings to configure

| Setting | Value |
|---------|-------|
| Theme | Light |
| Open at login | Yes |
| Microphone audio muting | Enabled |
| Streaming audio | Disabled |
| Auto-learn words | Enabled |
| OCR screen capture | Disabled |
| Sounds | Enabled |
| Share usage data | No |
| Auto polish | Disabled |
| Experimental model | Disabled |
| Tone match | Disabled |
| Haptics | Disabled |

### Keyboard shortcuts

| Shortcut | Action |
|----------|--------|
| Cmd (hold) | Push-to-talk |
| Option+Cmd | Push-on, pop-off (POPO) |
| Ctrl+Cmd | Lens |
| Shift+Cmd+Tab | Paste last text |

### Polish instructions (AI text refinement)

All enabled:
- Make more concise
- Reword for clarity
- Reorder for readability
- Add structure for readability
- Maintain tone

### Configuration location

Main config: `~/Library/Application Support/Wispr Flow/config.json`

Most settings sync via Google account login. After installing on the new machine, sign in and verify the keyboard shortcuts above are set.

---

## 11. Menubar & Utility Apps

### SpaceId

Shows the current macOS Space number in the menu bar. Essential for yabai workflow.

Install: `brew install --cask spaceid`

```bash
defaults write com.dshnkao.SpaceId launchOnLogin -bool true
defaults write com.dshnkao.SpaceId underlineActiveMonitor -bool true
defaults write com.dshnkao.SpaceId colorPref -int 1
defaults write com.dshnkao.SpaceId iconPref -int 1
```

### MeetingBar

Shows upcoming calendar meetings in the menu bar with one-click join.

Install: App Store (version 4.10.0).

Settings to configure after install:
- Event store provider: **macOS Calendar App**
- Default meeting service: **Google Meet**
- Event title length in menu bar: 15 characters
- Event time format: show
- Join event notification: 3 minutes before (180s)
- Select relevant calendars after linking

### Flux (f.lux)

Blue light filter. Install: Download from [justgetflux.com](https://justgetflux.com/).

```bash
# Location: Denver area
defaults write org.herf.Flux location "39.623700,-104.873800"
defaults write org.herf.Flux locationTextField -int 10019
defaults write org.herf.Flux locationType -string "L"

# Color temperatures
defaults write org.herf.Flux lateColorTemp -int 2300
defaults write org.herf.Flux nightColorTemp -int 6100

# Wake time: 8:00 AM (480 minutes from midnight)
defaults write org.herf.Flux wakeTime -int 480
```

### CleanShot X

Screenshot and screen recording tool. **Licensed** (key: `XTTBRHQR-YNLGHDZS-ZDKKTDHG-ZZJKPCQD`).

Install: Download from [cleanshot.com](https://cleanshot.com/).

Settings to configure after install:
- Capture without desktop icons: Enabled
- Delete popup after dragging: Enabled
- History capacity: 4
- Analytics: Disabled
- Auto-update: Disabled
- Annotation tools: draw, text, rectangle, arrow, filled rectangle, ellipse

### Tailscale

VPN mesh network. Install: App Store.

```bash
# Tailscale starts on login and maintains state across restarts
# Configuration syncs via Tailscale account -- just sign in
```

### 1Password

Password manager. Install: Download from [1password.com](https://1password.com/).

Settings to configure:
- Browser extension integration (Safari + Arc/Chrome)
- Sign in to vault after install

---

## 12. Vim Configuration

### ~/.vimrc

```vim
" Fix clipboard timeout on macOS
set clipboard=exclude:.*

set background=light
colorscheme solarized8_flat

au BufNewFile,BufRead *.go set filetype=go
au BufNewFile,BufRead *.md set filetype=markdown

command! Tabs set noexpandtab tabstop=4 shiftwidth=4
command! Spaces2 set expandtab softtabstop=2 shiftwidth=2
command! Spaces4 set expandtab softtabstop=4 shiftwidth=4
command! Spaces8 set expandtab softtabstop=2 shiftwidth=8
command! Tabs8 set tabstop==2 shiftwidth=8

Tabs
au Filetype cpp Spaces2
au Filetype javascript,javascript.jsx Spaces2
au Filetype python,markdown Spaces4

syntax on

set lazyredraw
set showmatch
set hlsearch

set directory^=/tmp//

filetype plugin indent on
set autoindent
set smartindent

set number

set ignorecase
set smartcase
set scrolloff=10

" Disable mouse to prevent clipboard timeout
set showcmd

set completeopt=preview

" Performance optimizations
set ttyfast
set regexpengine=1
set synmaxcol=200
set updatetime=300
set redrawtime=10000

nmap <space> <leader>
vmap <space> <leader>

inoremap jj <esc>
inoremap jJ <esc>
inoremap Jj <esc>
inoremap JJ <esc>

nnoremap ; :
vnoremap ; :
nnoremap <leader>w J
vnoremap <leader>a :w !xclip -sel clip<enter><enter>

nnoremap H gT
nnoremap L gt
nnoremap <C-h> H
nnoremap <C-l> L

nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

nnoremap gj j
nnoremap gk k
vnoremap gj j
vnoremap gk k

nnoremap J 8gj
nnoremap K 8gk
vnoremap J 8gj
vnoremap K 8gk

nnoremap gJ 8j
nnoremap gK 8k
vnoremap gJ 8j
vnoremap gK 8k

nnoremap <cr> o<esc>
nnoremap <C-a> <nop>
nnoremap <C-x> <nop>
```

**Vim color scheme:** Install solarized8:
```bash
mkdir -p ~/.vim/pack/themes/opt
git clone https://github.com/lifepillar/vim-solarized8.git ~/.vim/pack/themes/opt/solarized8
```

---

## 13. Editor Setup

### Cursor (primary editor)

Extensions:
```bash
cursor --install-extension anthropic.claude-code
cursor --install-extension anysphere.cursorpyright
cursor --install-extension batisteo.vscode-django
cursor --install-extension bdavs.expect
cursor --install-extension coderabbit.coderabbit-vscode
cursor --install-extension cognition.devin
cursor --install-extension coscreen-inc.coscreen-vsc-extension
cursor --install-extension cweijan.dbclient-jdbc
cursor --install-extension cweijan.vscode-mysql-client2
cursor --install-extension davidanson.vscode-markdownlint
cursor --install-extension dbaeumer.vscode-eslint
cursor --install-extension denoland.vscode-deno
cursor --install-extension donjayamanne.githistory
cursor --install-extension donjayamanne.python-environment-manager
cursor --install-extension donjayamanne.python-extension-pack
cursor --install-extension github.vscode-github-actions
cursor --install-extension grapecity.gc-excelviewer
cursor --install-extension hashicorp.terraform
cursor --install-extension idleberg.applescript
cursor --install-extension idleberg.jxa
cursor --install-extension jock.svg
cursor --install-extension kevinrose.vsc-python-indent
cursor --install-extension marimo-team.vscode-marimo
cursor --install-extension mechatroner.rainbow-csv
cursor --install-extension mermaidchart.vscode-mermaid-chart
cursor --install-extension mk12.better-git-line-blame
cursor --install-extension ms-azuretools.vscode-docker
cursor --install-extension ms-mssql.data-workspace-vscode
cursor --install-extension ms-mssql.mssql
cursor --install-extension ms-mssql.sql-bindings-vscode
cursor --install-extension ms-mssql.sql-database-projects-vscode
cursor --install-extension ms-playwright.playwright
cursor --install-extension ms-python.black-formatter
cursor --install-extension ms-python.debugpy
cursor --install-extension ms-python.python
cursor --install-extension ms-toolsai.jupyter
cursor --install-extension ms-toolsai.jupyter-keymap
cursor --install-extension ms-toolsai.jupyter-renderers
cursor --install-extension ms-toolsai.vscode-jupyter-cell-tags
cursor --install-extension ms-toolsai.vscode-jupyter-slideshow
cursor --install-extension ms-vscode-remote.remote-containers
cursor --install-extension ms-vsliveshare.vsliveshare
cursor --install-extension njpwerner.autodocstring
cursor --install-extension openai.openai-chatgpt-adhoc
cursor --install-extension sinclair.react-developer-tools
cursor --install-extension supabase.postgrestools
cursor --install-extension tamasfe.even-better-toml
cursor --install-extension tomoki1207.pdf
cursor --install-extension visualstudioexptteam.intellicode-api-usage-examples
cursor --install-extension visualstudioexptteam.vscodeintellicode
cursor --install-extension vscodevim.vim
cursor --install-extension wholroyd.jinja
cursor --install-extension withfig.fig
```

### VS Code (secondary)

Extensions:
```bash
code --install-extension bdavs.expect
code --install-extension DavidAnson.vscode-markdownlint
code --install-extension denoland.vscode-deno
code --install-extension donjayamanne.githistory
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
code --install-extension idleberg.applescript
code --install-extension jock.svg
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-python.black-formatter
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-toolsai.jupyter
code --install-extension ms-toolsai.jupyter-keymap
code --install-extension ms-toolsai.jupyter-renderers
code --install-extension ms-toolsai.vscode-jupyter-cell-tags
code --install-extension ms-toolsai.vscode-jupyter-slideshow
code --install-extension ms-vscode-remote.remote-containers
code --install-extension vscodevim.vim
code --install-extension withfig.fig
```

---

## 14. Claude Code

### ~/.claude/settings.json

```json
{
  "enabledPlugins": {
    "pg@aiguide": true,
    "playwright@claude-plugins-official": true,
    "document-skills@anthropic-agent-skills": true,
    "frontend-design@claude-plugins-official": true,
    "ralph-wiggum@claude-plugins-official": true,
    "pr-review-toolkit@claude-plugins-official": true,
    "ralph-loop@claude-plugins-official": true
  }
}
```

Install Claude Code:
```bash
npm install -g @anthropic-ai/claude-code
```

---

## 15. macOS System Preferences

All settings below differ from macOS defaults. Run these `defaults write` commands to replicate.

### Keyboard & input

```bash
# Fast key repeat (InitialKeyRepeat=15 is ~225ms, KeyRepeat=2 is ~30ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 2

# Mouse: fast tracking speed (2.5), double-click threshold relaxed
defaults write NSGlobalDomain "com.apple.mouse.scaling" -float 2.5
defaults write NSGlobalDomain "com.apple.mouse.doubleClickThreshold" -float 1.1

# Trackpad: fast tracking speed (2.5), natural scrolling ON, force click ON
defaults write NSGlobalDomain "com.apple.trackpad.scaling" -float 2.5
defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool true
defaults write NSGlobalDomain "com.apple.trackpad.forceClick" -bool true

# Scroll wheel: moderate speed
defaults write NSGlobalDomain "com.apple.scrollwheel.scaling" -float 0.5

# Trackpad: tap-to-click OFF (physical click), two-finger right-click ON
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll -int 1

# Mouse: OneButton mode
defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string "OneButton"
```

### Keyboard shortcuts (symbolichotkeys)

**Desktop switching via Ctrl+1 through Ctrl+0** is enabled for all 10 desktops. Most other Mission Control keyboard shortcuts are **disabled** (yabai/skhd handles window management instead). All built-in screenshot shortcuts are **disabled** (CleanShot X is used instead).

```bash
# Enable Ctrl+1 through Ctrl+0 for desktop switching
# Keys 118-127 map to Switch to Desktop 1-10
# Each entry: enabled=1, modifier=262144 (Ctrl), keycode=18-29 (1-0 keys)
for i in {0..9}; do
    id=$((118 + i))
    keycode=$((18 + i))
    # Key 0 is keycode 29
    if [ $i -eq 9 ]; then keycode=29; fi
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" "
        <dict>
            <key>enabled</key><true/>
            <key>value</key><dict>
                <key>parameters</key>
                <array>
                    <integer>65535</integer>
                    <integer>$keycode</integer>
                    <integer>262144</integer>
                </array>
                <key>type</key><string>standard</string>
            </dict>
        </dict>"
done

# Disable built-in screenshot shortcuts (using CleanShot X instead)
for id in 28 29 30 31 184; do
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" "
        <dict><key>enabled</key><false/></dict>"
done

# Disable Mission Control / Spaces keyboard shortcuts (using yabai/skhd)
for id in 15 16 17 18 19 20 21 22 23 24 25 26; do
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" "
        <dict><key>enabled</key><false/></dict>"
done

# Disable Dock hiding shortcut (Cmd+Option+D)
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "52" "
    <dict><key>enabled</key><false/></dict>"

# Keep Spotlight at Cmd+Space (enabled, ID 32 -- this is default)
```

### Appearance & animations

```bash
# Light mode (default -- no AppleInterfaceStyle key needed)
# Accent/highlight color: system default multicolor (no override needed)

# Disable window opening/closing animations
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Near-instant window resize (default is 0.2)
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Disable UI sounds
defaults write NSGlobalDomain "com.apple.sound.uiaudio.enabled" -bool false

# Beep volume at ~45%
defaults write NSGlobalDomain "com.apple.sound.beep.volume" -float 0.4536978

# Flash screen on beep: OFF
defaults write NSGlobalDomain "com.apple.sound.beep.flash" -bool false

# Scrollbars: automatic
defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"

# Double-click title bar does NOT minimize
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false

# Resume windows on relaunch
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true
```

### Dock

```bash
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 56
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock mru-spaces -bool false

# Apply
killall Dock
```

**Dock pinned apps (left to right):** Launchpad, Arc, Messages, Superhuman, Slack, Cursor, iTerm, Notion, Spotify, Calendar, System Settings, Reminders, ChatGPT. **Right side:** Downloads folder (stack, sorted by date added).

### Finder

```bash
# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show external drives & removable media on desktop, hide internal drives
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# No warning when emptying trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# Sidebar shown, status bar hidden
defaults write com.apple.finder ShowSidebar -bool true
defaults write com.apple.finder ShowStatusBar -bool false

# Apply
killall Finder
```

### Clock & menu bar

```bash
# 12-hour, show AM/PM, show day of week, hide date
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true

# Hide Siri from menu bar
defaults write com.apple.Siri StatusMenuVisible -bool false

# Hide text input menu from menu bar
defaults write com.apple.TextInputMenu visible -bool false
```

### Window Manager / Spaces

```bash
# Stage Manager OFF
defaults write com.apple.WindowManager GloballyEnabled -bool false

# Click desktop does NOT show desktop
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# No margins between tiled windows
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
```

### Accessibility

```bash
# Reduce motion ON (reduces parallax, auto-play, etc.)
defaults write com.apple.universalaccess reduceMotion -bool true
```

### Siri

```bash
# Siri not on lock screen, not in menu bar, but "Hey Siri" is enabled
defaults write com.apple.Siri LockscreenEnabled -bool false
defaults write com.apple.Siri StatusMenuVisible -bool false
defaults write com.apple.Siri VoiceTriggerUserEnabled -bool true
```

### Text replacements

```bash
# "omw" -> "On my way!"
defaults write NSGlobalDomain NSUserDictionaryReplacementItems -array \
    '{ on = 1; replace = omw; with = "On my way!"; }'
```

### Spaces / Desktops

Create **12 desktops** on the primary display. This must be done manually:
- Open Mission Control (swipe up with 4 fingers or Ctrl+Up)
- Click "+" in the top-right to add desktops until you have 12

### Manual settings to verify

These can't be fully set via `defaults write` -- verify in System Settings after running the script:

- **Trackpad:** Physical click (tap-to-click OFF), two-finger right-click ON, momentum scrolling ON
- **Mouse:** Natural scrolling ON, tracking speed near max
- **Keyboard > Shortcuts > Mission Control:** Ctrl+1 through Ctrl+0 for desktops 1-10
- **Control Center:** Battery, Bluetooth, WiFi, Focus Modes, Clock visible; Screen Mirroring in menu bar
- **Spaces:** 12 desktops created, "Automatically rearrange" OFF

---

## 16. Applications (non-Homebrew)

These apps are installed outside of Homebrew (App Store, direct download, etc.):

| App | Source | Notes |
|-----|--------|-------|
| Arc | Direct download | Primary browser |
| 1Password | Direct download | Password manager |
| Alfred 5 | Direct download | Launcher (alt-d hotkey) |
| Anki | Direct download | Flashcards |
| Bitwarden | Direct download | Backup password manager |
| ChatGPT | Direct download | OpenAI desktop app |
| Claude | Direct download | Anthropic desktop app |
| CleanShot X | Direct download | Screenshot tool |
| Comet | Direct download | |
| CoScreen | Direct download | Screen sharing |
| Cryptomator | Direct download | Encryption |
| Discord | Direct download | Chat |
| Dropbox | Direct download | File sync |
| Dynalist | Direct download | Outliner |
| Flux | Direct download | Blue light filter |
| Google Chrome | Direct download | Secondary browser |
| Graphite | Direct download | Stacked PRs |
| Linear | Direct download | Project management |
| MeetingBar | Direct download | Calendar in menu bar |
| Microsoft Excel | Direct download / Office | |
| Microsoft Outlook | Direct download / Office | |
| Microsoft Word | Direct download / Office | |
| Microsoft Teams | Direct download / Office | |
| Microsoft PowerPoint | Direct download / Office | |
| Notion | Direct download | Notes/wiki |
| Ollama | Direct download | Local LLM runner |
| OneDrive | Direct download | Cloud storage |
| Parallels Desktop | Direct download | VM |
| Private Internet Access | Direct download | VPN |
| Rewind | Direct download | AI recall |
| Signal | Direct download | Messaging |
| Slack | Direct download | Team chat |
| Steam | Direct download | Games |
| Superhuman | Direct download | Email client |
| TablePlus | Direct download | Database GUI |
| Tailscale | Direct download | VPN mesh |
| Wispr Flow | Direct download | Voice-to-text |
| Zoom | Direct download | Video calls |

---

## 17. Browser Extensions

### Arc / Chrome

- Vimium
- Toucan
- Adblock
- Bitwarden

---

## 18. Secrets & API Keys

**DO NOT commit these.** On the new machine, set these environment variables (e.g. in a `~/.secrets` file sourced from `.zshrc`):

```bash
# ~/.secrets (chmod 600)
export OPENAI_API_KEY='...'
export GEMINI_API_KEY='...'
export OAGI_API_KEY='...'
export OAGI_BASE_URL=https://api.agiopen.org
```

Then add to `.zshrc`:
```bash
[ -f ~/.secrets ] && source ~/.secrets
```

Other credentials to set up:
- `gh auth login` -- GitHub CLI
- `gcloud auth login` -- Google Cloud
- `~/.modal.toml` -- Modal.com tokens
- `~/.config/graphite/user_config` -- Graphite auth token
- `~/.config/rclone/rclone.conf` -- Google Drive OAuth (run `rclone config`)
- `~/.config/marimo/marimo.toml` -- OpenAI key for marimo

---

## 19. Services & Launch Agents

Active services:

| Service | How to start |
|---------|-------------|
| PostgreSQL 16 | `brew services start postgresql@16` |
| yabai | `yabai --start-service` |
| skhd | `skhd --start-service` |
| Hammerspoon | Launch from Applications (set to open at login) |
| Karabiner-Elements | Launch from Applications (set to open at login) |
| SpaceId | Launch from Applications (set to open at login) |
| Rectangle | Launch from Applications (set to open at login) |
| Alfred 5 | Launch from Applications (set to open at login) |
| Wispr Flow | Launch from Applications (set to open at login) |
| CleanShot X | Launch from Applications (set to open at login) |
| MeetingBar | Launch from Applications (set to open at login) |
| Flux | Launch from Applications (set to open at login) |
| 1Password | Launch from Applications (set to open at login) |
| Tailscale | Launch from Applications (set to open at login) |
| Rewind | Launch from Applications (set to open at login) |

---

## 20. SSH Keys

Generate new keys on the new machine:

```bash
ssh-keygen -t ed25519 -C "1tolsmar@gmail.com"
# Add to GitHub: https://github.com/settings/keys
cat ~/.ssh/id_ed25519.pub | pbcopy
```

The SSH config includes OrbStack integration:
```
Include ~/.orbstack/ssh/config
```
