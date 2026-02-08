#!/usr/bin/env bash
#
# Ryan's Mac Setup Script
# Run on a fresh Apple Silicon Mac to replicate the dev environment.
# Usage: bash setup.sh
#
# This script is idempotent -- safe to re-run.
# Some steps require manual intervention (noted with MANUAL tags).
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Ryan's Mac Setup ==="
echo "Dotfiles dir: $DOTFILES_DIR"
echo ""

# ------------------------------------------------------------------
# 1. Xcode Command Line Tools
# ------------------------------------------------------------------
echo "--- Step 1: Xcode CLT ---"
if ! xcode-select -p &>/dev/null; then
    echo "Installing Xcode Command Line Tools..."
    xcode-select --install
    echo "MANUAL: Press Install in the dialog, then re-run this script."
    exit 0
else
    echo "Xcode CLT already installed."
fi

# ------------------------------------------------------------------
# 2. Homebrew
# ------------------------------------------------------------------
echo "--- Step 2: Homebrew ---"
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed."
fi

# ------------------------------------------------------------------
# 3. Brew Bundle
# ------------------------------------------------------------------
echo "--- Step 3: Brew packages ---"
brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock

# Start services
brew services start postgresql@16 2>/dev/null || true

# ------------------------------------------------------------------
# 4. Shell config files
# ------------------------------------------------------------------
echo "--- Step 4: Shell config ---"

link_dotfile() {
    local src="$1"
    local dest="$2"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "  Backing up existing $dest -> ${dest}.backup"
        mv "$dest" "${dest}.backup"
    fi
    if [ -L "$dest" ]; then
        echo "  $dest already linked."
    else
        echo "  Linking $src -> $dest"
        ln -sf "$src" "$dest"
    fi
}

# Download git-prompt.sh if missing
if [ ! -f "$HOME/.git-prompt.sh" ]; then
    echo "  Downloading git-prompt.sh..."
    curl -sfo "$HOME/.git-prompt.sh" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
fi

# Link dotfiles
for f in .zshrc .zprofile .zshenv .gitconfig .vimrc .yabairc .yabai-focus.sh .skhdrc .tool-versions .python-version; do
    if [ -f "$DOTFILES_DIR/$f" ]; then
        link_dotfile "$DOTFILES_DIR/$f" "$HOME/$f"
    fi
done

chmod +x "$HOME/.yabai-focus.sh" 2>/dev/null || true
chmod +x "$HOME/.yabairc" 2>/dev/null || true

# Config directories
mkdir -p "$HOME/.config/git"
mkdir -p "$HOME/.config/gh"
mkdir -p "$HOME/.config/jj"
mkdir -p "$HOME/.config/karabiner"
mkdir -p "$HOME/.claude"
mkdir -p "$HOME/.ssh"

[ -f "$DOTFILES_DIR/config/git/ignore" ] && cp "$DOTFILES_DIR/config/git/ignore" "$HOME/.config/git/ignore"
[ -f "$DOTFILES_DIR/config/gh/config.yml" ] && cp "$DOTFILES_DIR/config/gh/config.yml" "$HOME/.config/gh/config.yml"
[ -f "$DOTFILES_DIR/config/jj/config.toml" ] && cp "$DOTFILES_DIR/config/jj/config.toml" "$HOME/.config/jj/config.toml"
[ -f "$DOTFILES_DIR/config/karabiner/karabiner.json" ] && cp "$DOTFILES_DIR/config/karabiner/karabiner.json" "$HOME/.config/karabiner/karabiner.json"
[ -f "$DOTFILES_DIR/config/claude/settings.json" ] && cp "$DOTFILES_DIR/config/claude/settings.json" "$HOME/.claude/settings.json"
[ -f "$DOTFILES_DIR/config/ssh/config" ] && cp "$DOTFILES_DIR/config/ssh/config" "$HOME/.ssh/config"

# Secrets template
if [ ! -f "$HOME/.secrets" ]; then
    echo "  Copying .secrets.template -> ~/.secrets (fill in your keys)"
    cp "$DOTFILES_DIR/.secrets.template" "$HOME/.secrets"
    chmod 600 "$HOME/.secrets"
fi

# ------------------------------------------------------------------
# 4b. Editor configurations (Cursor + VS Code)
# ------------------------------------------------------------------
echo "--- Step 4b: Editor configs ---"

# Cursor
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
mkdir -p "$CURSOR_USER_DIR"
[ -f "$DOTFILES_DIR/config/cursor/settings.json" ] && cp "$DOTFILES_DIR/config/cursor/settings.json" "$CURSOR_USER_DIR/settings.json"
[ -f "$DOTFILES_DIR/config/cursor/keybindings.json" ] && cp "$DOTFILES_DIR/config/cursor/keybindings.json" "$CURSOR_USER_DIR/keybindings.json"

# Cursor MCP config
mkdir -p "$HOME/.cursor"
[ -f "$DOTFILES_DIR/config/cursor/mcp.json" ] && cp "$DOTFILES_DIR/config/cursor/mcp.json" "$HOME/.cursor/mcp.json"

# VS Code
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
mkdir -p "$VSCODE_USER_DIR"
[ -f "$DOTFILES_DIR/config/vscode/settings.json" ] && cp "$DOTFILES_DIR/config/vscode/settings.json" "$VSCODE_USER_DIR/settings.json"

# ------------------------------------------------------------------
# 4c. Fonts
# ------------------------------------------------------------------
echo "--- Step 4c: Fonts ---"
mkdir -p "$HOME/Library/Fonts"
if [ -d "$DOTFILES_DIR/fonts" ]; then
    cp "$DOTFILES_DIR/fonts/"*.otf "$HOME/Library/Fonts/" 2>/dev/null || true
    echo "  Fonts installed."
fi

# ------------------------------------------------------------------
# 4d. iTerm2 preferences
# ------------------------------------------------------------------
echo "--- Step 4d: iTerm2 preferences ---"
if [ -f "$DOTFILES_DIR/config/iterm2/com.googlecode.iterm2.plist" ]; then
    defaults import com.googlecode.iterm2 "$DOTFILES_DIR/config/iterm2/com.googlecode.iterm2.plist"
    echo "  iTerm2 preferences imported."
fi

# ------------------------------------------------------------------
# 4e. Alfred preferences
# ------------------------------------------------------------------
echo "--- Step 4e: Alfred preferences ---"
ALFRED_SUPPORT="$HOME/Library/Application Support/Alfred"
if [ -d "$DOTFILES_DIR/config/alfred/Alfred.alfredpreferences" ]; then
    mkdir -p "$ALFRED_SUPPORT"
    cp -R "$DOTFILES_DIR/config/alfred/Alfred.alfredpreferences" "$ALFRED_SUPPORT/"
    [ -f "$DOTFILES_DIR/config/alfred/prefs.json" ] && cp "$DOTFILES_DIR/config/alfred/prefs.json" "$ALFRED_SUPPORT/"
    echo "  Alfred preferences deployed."
    echo "  MANUAL: Activate Powerpack license (key: YOUR_ALFRED_LICENSE)"
fi

# ------------------------------------------------------------------
# 5. Version managers
# ------------------------------------------------------------------
echo "--- Step 5: Version managers ---"

# asdf
if [ ! -d "$HOME/.asdf" ]; then
    echo "  Installing asdf..."
    git clone https://github.com/asdf-vm/asdf.git "$HOME/.asdf" --branch v0.14.0
fi
source "$HOME/.asdf/asdf.sh"

asdf plugin add ruby 2>/dev/null || true
asdf plugin add nodejs 2>/dev/null || true
asdf install ruby 3.2.2 2>/dev/null || true
asdf install nodejs 22.12.0 2>/dev/null || true
asdf global ruby 3.2.2
asdf global nodejs 22.12.0

# Rust
if ! command -v rustc &>/dev/null; then
    echo "  Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

# Rye
if [ ! -d "$HOME/.rye" ]; then
    echo "  Installing Rye..."
    curl -sSf https://rye.astral.sh/get | bash
fi

# Bun
if ! command -v bun &>/dev/null; then
    echo "  Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
fi

# Google Cloud SDK
if [ ! -d "$HOME/google-cloud-sdk" ]; then
    echo "  MANUAL: Install Google Cloud SDK from https://cloud.google.com/sdk/docs/install"
fi

# ------------------------------------------------------------------
# 6. Global npm packages
# ------------------------------------------------------------------
echo "--- Step 6: Global npm packages ---"
npm install -g @openai/codex cursor-tools happy-coder pnpm pyright @anthropic-ai/claude-code 2>/dev/null || true

# ------------------------------------------------------------------
# 7. Vim color scheme
# ------------------------------------------------------------------
echo "--- Step 7: Vim setup ---"
if [ ! -d "$HOME/.vim/pack/themes/opt/solarized8" ]; then
    mkdir -p "$HOME/.vim/pack/themes/opt"
    git clone https://github.com/lifepillar/vim-solarized8.git "$HOME/.vim/pack/themes/opt/solarized8"
fi

# ------------------------------------------------------------------
# 8. Hammerspoon + stackline
# ------------------------------------------------------------------
echo "--- Step 8: Hammerspoon ---"
mkdir -p "$HOME/.hammerspoon"
if [ ! -d "$HOME/.hammerspoon/stackline" ]; then
    git clone https://github.com/AdamWagworski/stackline.git "$HOME/.hammerspoon/stackline"
fi
if [ -f "$DOTFILES_DIR/.hammerspoon/init.lua" ]; then
    cp "$DOTFILES_DIR/.hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"
fi

# ------------------------------------------------------------------
# 9. Window management services
# ------------------------------------------------------------------
echo "--- Step 9: Window management ---"
skhd --start-service 2>/dev/null || true
yabai --start-service 2>/dev/null || true

echo ""
echo "MANUAL: Configure yabai scripting addition:"
echo '  echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai'

# ------------------------------------------------------------------
# 10. macOS defaults
# ------------------------------------------------------------------
echo "--- Step 10: macOS preferences ---"

# --- Keyboard & Input ---
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain "com.apple.mouse.scaling" -float 2.5
defaults write NSGlobalDomain "com.apple.mouse.doubleClickThreshold" -float 1.1
defaults write NSGlobalDomain "com.apple.trackpad.scaling" -float 2.5
defaults write NSGlobalDomain "com.apple.swipescrolldirection" -bool true
defaults write NSGlobalDomain "com.apple.trackpad.forceClick" -bool true
defaults write NSGlobalDomain "com.apple.scrollwheel.scaling" -float 0.5
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -int 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll -int 1
defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string "OneButton"

# --- Appearance & Animations ---
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write NSGlobalDomain "com.apple.sound.uiaudio.enabled" -bool false
defaults write NSGlobalDomain "com.apple.sound.beep.volume" -float 0.4536978
defaults write NSGlobalDomain "com.apple.sound.beep.flash" -bool false
defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"
defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool false
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool true

# --- Text Corrections ---
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false

# --- Dock ---
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 56
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock mru-spaces -bool false

# --- Finder ---
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
defaults write com.apple.finder WarnOnEmptyTrash -bool false
defaults write com.apple.finder ShowSidebar -bool true
defaults write com.apple.finder ShowStatusBar -bool false

# --- Clock & Menu Bar ---
defaults write com.apple.menuextra.clock ShowAMPM -bool true
defaults write com.apple.menuextra.clock ShowDate -int 0
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.Siri StatusMenuVisible -bool false
defaults write com.apple.Siri LockscreenEnabled -bool false
defaults write com.apple.Siri VoiceTriggerUserEnabled -bool true
defaults write com.apple.TextInputMenu visible -bool false

# --- Window Manager ---
defaults write com.apple.WindowManager GloballyEnabled -bool false
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# --- Accessibility ---
defaults write com.apple.universalaccess reduceMotion -bool true

# --- Hot Corners: all disabled ---
defaults write com.apple.dock wvous-tl-corner -int 1
defaults write com.apple.dock wvous-tr-corner -int 1
defaults write com.apple.dock wvous-bl-corner -int 1
defaults write com.apple.dock wvous-br-corner -int 1
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

# --- Keyboard Shortcuts: Ctrl+1-0 for desktops ---
for i in $(seq 0 9); do
    id=$((118 + i))
    keycode=$((18 + i))
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

# --- Disable built-in screenshot shortcuts (using CleanShot X) ---
for id in 28 29 30 31 184; do
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" \
        "<dict><key>enabled</key><false/></dict>"
done

# --- Disable Mission Control keyboard shortcuts (using yabai/skhd) ---
for id in 15 16 17 18 19 20 21 22 23 24 25 26 52; do
    defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$id" \
        "<dict><key>enabled</key><false/></dict>"
done

# --- Text Replacements ---
defaults write NSGlobalDomain NSUserDictionaryReplacementItems -array \
    '{ on = 1; replace = omw; with = "On my way!"; }'

# --- Apply ---
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

# ------------------------------------------------------------------
# 10b. Menubar & utility app defaults
# ------------------------------------------------------------------
echo "--- Step 10b: Menubar & utility app preferences ---"

# SpaceId
defaults write com.dshnkao.SpaceId launchOnLogin -bool true
defaults write com.dshnkao.SpaceId underlineActiveMonitor -bool true
defaults write com.dshnkao.SpaceId colorPref -int 1
defaults write com.dshnkao.SpaceId iconPref -int 1

# Flux (f.lux) -- Denver area
defaults write org.herf.Flux location "39.623700,-104.873800"
defaults write org.herf.Flux locationTextField -int 10019
defaults write org.herf.Flux locationType -string "L"
defaults write org.herf.Flux lateColorTemp -int 2300
defaults write org.herf.Flux nightColorTemp -int 6100
defaults write org.herf.Flux wakeTime -int 480

# CleanShot X
defaults write pl.maketheweb.cleanshotx captureWithoutDesktopIcons -bool true
defaults write pl.maketheweb.cleanshotx deletePopupAfterDragging -bool true
defaults write pl.maketheweb.cleanshotx historyCapacity -int 4
defaults write pl.maketheweb.cleanshotx analyticsAllowed -bool false
defaults write pl.maketheweb.cleanshotx SUAutomaticallyUpdate -bool false
defaults write pl.maketheweb.cleanshotx SUEnableAutomaticChecks -bool false

# ------------------------------------------------------------------
# 10c. Energy settings
# ------------------------------------------------------------------
echo "--- Step 10c: Energy settings ---"
sudo pmset -b displaysleep 3 sleep 1 disksleep 10 2>/dev/null || echo "  (skipped -- needs sudo)"
sudo pmset -c displaysleep 10 sleep 1 disksleep 10 2>/dev/null || echo "  (skipped -- needs sudo)"

# ------------------------------------------------------------------
# 10d. Dock apps
# ------------------------------------------------------------------
echo "--- Step 10d: Dock apps ---"
if command -v dockutil &>/dev/null; then
    dockutil --remove all --no-restart 2>/dev/null || true
    dockutil --add "/Applications/Arc.app" --no-restart 2>/dev/null || true
    dockutil --add "/System/Applications/Messages.app" --no-restart 2>/dev/null || true
    dockutil --add "/Applications/Superhuman.app" --no-restart 2>/dev/null || true
    dockutil --add "/Applications/Slack.app" --no-restart 2>/dev/null || true
    dockutil --add "/Applications/Cursor.app" --no-restart 2>/dev/null || true
    dockutil --add "/Applications/iTerm.app" --no-restart 2>/dev/null || true
    dockutil --add "/Applications/Notion.app" --no-restart 2>/dev/null || true
    dockutil --add "/Applications/Spotify.app" --no-restart 2>/dev/null || true
    dockutil --add "/System/Applications/Calendar.app" --no-restart 2>/dev/null || true
    dockutil --add "/System/Applications/System Settings.app" --no-restart 2>/dev/null || true
    dockutil --add "/System/Applications/Reminders.app" --no-restart 2>/dev/null || true
    dockutil --add "/Applications/ChatGPT.app" --no-restart 2>/dev/null || true
    killall Dock 2>/dev/null || true
    echo "  Dock configured."
else
    echo "  dockutil not found, skipping dock setup."
fi

# ------------------------------------------------------------------
# 10e. Login items
# ------------------------------------------------------------------
echo "--- Step 10e: Login items ---"
LOGIN_APPS=(
    "Dropbox"
    "MeetingBar"
    "Notion"
    "SpaceId"
    "Superhuman"
    "CleanShot X"
    "OrbStack"
    "Alfred 5"
    "Hammerspoon"
    "Flux"
    "Graphite"
    "1Password"
    "Tailscale"
)
for app in "${LOGIN_APPS[@]}"; do
    osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"/Applications/${app}.app\", hidden:false}" 2>/dev/null || true
done
echo "  Login items configured."

# ------------------------------------------------------------------
# 10f. Wallpaper
# ------------------------------------------------------------------
echo "--- Step 10f: Wallpaper ---"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
mkdir -p "$WALLPAPER_DIR"
if [ -f "$DOTFILES_DIR/wallpapers/Riverside by ArseniXC.heic" ]; then
    cp "$DOTFILES_DIR/wallpapers/Riverside by ArseniXC.heic" "$WALLPAPER_DIR/"
    osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$WALLPAPER_DIR/Riverside by ArseniXC.heic\"" 2>/dev/null || true
    echo "  Wallpaper set."
fi

# ------------------------------------------------------------------
# 11. Editor extensions
# ------------------------------------------------------------------
echo "--- Step 11: Editor extensions ---"

if command -v cursor &>/dev/null; then
    echo "  Installing Cursor extensions..."
    cursor --install-extension anthropic.claude-code 2>/dev/null || true
    cursor --install-extension anysphere.cursorpyright 2>/dev/null || true
    cursor --install-extension batisteo.vscode-django 2>/dev/null || true
    cursor --install-extension bdavs.expect 2>/dev/null || true
    cursor --install-extension coderabbit.coderabbit-vscode 2>/dev/null || true
    cursor --install-extension cognition.devin 2>/dev/null || true
    cursor --install-extension coscreen-inc.coscreen-vsc-extension 2>/dev/null || true
    cursor --install-extension cweijan.dbclient-jdbc 2>/dev/null || true
    cursor --install-extension cweijan.vscode-mysql-client2 2>/dev/null || true
    cursor --install-extension davidanson.vscode-markdownlint 2>/dev/null || true
    cursor --install-extension dbaeumer.vscode-eslint 2>/dev/null || true
    cursor --install-extension denoland.vscode-deno 2>/dev/null || true
    cursor --install-extension donjayamanne.githistory 2>/dev/null || true
    cursor --install-extension donjayamanne.python-environment-manager 2>/dev/null || true
    cursor --install-extension donjayamanne.python-extension-pack 2>/dev/null || true
    cursor --install-extension github.vscode-github-actions 2>/dev/null || true
    cursor --install-extension grapecity.gc-excelviewer 2>/dev/null || true
    cursor --install-extension hashicorp.terraform 2>/dev/null || true
    cursor --install-extension idleberg.applescript 2>/dev/null || true
    cursor --install-extension idleberg.jxa 2>/dev/null || true
    cursor --install-extension jock.svg 2>/dev/null || true
    cursor --install-extension kevinrose.vsc-python-indent 2>/dev/null || true
    cursor --install-extension marimo-team.vscode-marimo 2>/dev/null || true
    cursor --install-extension mechatroner.rainbow-csv 2>/dev/null || true
    cursor --install-extension mermaidchart.vscode-mermaid-chart 2>/dev/null || true
    cursor --install-extension mk12.better-git-line-blame 2>/dev/null || true
    cursor --install-extension ms-azuretools.vscode-docker 2>/dev/null || true
    cursor --install-extension ms-mssql.data-workspace-vscode 2>/dev/null || true
    cursor --install-extension ms-mssql.mssql 2>/dev/null || true
    cursor --install-extension ms-mssql.sql-bindings-vscode 2>/dev/null || true
    cursor --install-extension ms-mssql.sql-database-projects-vscode 2>/dev/null || true
    cursor --install-extension ms-playwright.playwright 2>/dev/null || true
    cursor --install-extension ms-python.black-formatter 2>/dev/null || true
    cursor --install-extension ms-python.debugpy 2>/dev/null || true
    cursor --install-extension ms-python.python 2>/dev/null || true
    cursor --install-extension ms-toolsai.jupyter 2>/dev/null || true
    cursor --install-extension ms-toolsai.jupyter-keymap 2>/dev/null || true
    cursor --install-extension ms-toolsai.jupyter-renderers 2>/dev/null || true
    cursor --install-extension ms-toolsai.vscode-jupyter-cell-tags 2>/dev/null || true
    cursor --install-extension ms-toolsai.vscode-jupyter-slideshow 2>/dev/null || true
    cursor --install-extension ms-vscode-remote.remote-containers 2>/dev/null || true
    cursor --install-extension ms-vsliveshare.vsliveshare 2>/dev/null || true
    cursor --install-extension njpwerner.autodocstring 2>/dev/null || true
    cursor --install-extension openai.openai-chatgpt-adhoc 2>/dev/null || true
    cursor --install-extension sinclair.react-developer-tools 2>/dev/null || true
    cursor --install-extension supabase.postgrestools 2>/dev/null || true
    cursor --install-extension tamasfe.even-better-toml 2>/dev/null || true
    cursor --install-extension tomoki1207.pdf 2>/dev/null || true
    cursor --install-extension visualstudioexptteam.intellicode-api-usage-examples 2>/dev/null || true
    cursor --install-extension visualstudioexptteam.vscodeintellicode 2>/dev/null || true
    cursor --install-extension vscodevim.vim 2>/dev/null || true
    cursor --install-extension wholroyd.jinja 2>/dev/null || true
    cursor --install-extension withfig.fig 2>/dev/null || true
fi

if command -v code &>/dev/null; then
    echo "  Installing VS Code extensions..."
    code --install-extension bdavs.expect 2>/dev/null || true
    code --install-extension DavidAnson.vscode-markdownlint 2>/dev/null || true
    code --install-extension denoland.vscode-deno 2>/dev/null || true
    code --install-extension donjayamanne.githistory 2>/dev/null || true
    code --install-extension GitHub.copilot 2>/dev/null || true
    code --install-extension GitHub.copilot-chat 2>/dev/null || true
    code --install-extension idleberg.applescript 2>/dev/null || true
    code --install-extension jock.svg 2>/dev/null || true
    code --install-extension ms-azuretools.vscode-docker 2>/dev/null || true
    code --install-extension ms-python.black-formatter 2>/dev/null || true
    code --install-extension ms-python.python 2>/dev/null || true
    code --install-extension ms-python.vscode-pylance 2>/dev/null || true
    code --install-extension ms-toolsai.jupyter 2>/dev/null || true
    code --install-extension ms-toolsai.jupyter-keymap 2>/dev/null || true
    code --install-extension ms-toolsai.jupyter-renderers 2>/dev/null || true
    code --install-extension ms-toolsai.vscode-jupyter-cell-tags 2>/dev/null || true
    code --install-extension ms-toolsai.vscode-jupyter-slideshow 2>/dev/null || true
    code --install-extension ms-vscode-remote.remote-containers 2>/dev/null || true
    code --install-extension vscodevim.vim 2>/dev/null || true
    code --install-extension withfig.fig 2>/dev/null || true
fi

# ------------------------------------------------------------------
# 12. SSH
# ------------------------------------------------------------------
echo "--- Step 12: SSH ---"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    echo "  MANUAL: Generate SSH key:"
    echo '    ssh-keygen -t ed25519 -C "1tolsmar@gmail.com"'
    echo "    Then add to GitHub: https://github.com/settings/keys"
fi

# ------------------------------------------------------------------
# 13. Final reminders
# ------------------------------------------------------------------
echo ""
echo "--- MANUAL: Remaining setup ---"
echo "1. Fill in ~/.secrets with API keys (see .secrets.template)"
echo "2. Run: gh auth login"
echo "3. Run: gcloud auth login"
echo "4. Set up Modal: edit ~/.modal.toml"
echo "5. Set up Graphite: gt auth"
echo "6. Alfred: activate Powerpack license (YOUR_ALFRED_LICENSE), set hotkey Ctrl+D,"
echo "   clipboard history Ctrl+C, terminal to iTerm, theme Modern Dark"
echo "7. CleanShot X: activate license (YOUR_CLEANSHOT_LICENSE)"
echo "8. Wispr Flow: sign in with Google, verify keyboard shortcuts"
echo "9. Create 12 desktops: Mission Control > click '+' until you have 12"
echo "10. Grant accessibility permissions (System Settings > Privacy):"
echo "    skhd, yabai, Hammerspoon, Alfred, Homerow, iTerm2"
echo "11. Grant screen recording permissions:"
echo "    Chrome, iTerm2, Slack, Discord, Teams, Zoom, Arc, CleanShot X"
echo "12. Sign in to: 1Password, Dropbox, Google Drive, OneDrive,"
echo "    Slack, Discord, Notion, Superhuman, Linear, Tailscale"
echo "13. Install browser extensions: Vimium, Toucan, Adblock, Bitwarden"
echo ""
echo "=== Setup complete ==="
