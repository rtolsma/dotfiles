# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"


fpath=(${ASDF_DIR}/completions $fpath) # Asdf completions
fpath=($HOMEBREW_PREFIX/share/zsh/site-functions $fpath) # just completions
autoload -Uz compinit && compinit
#

# Created by `pipx` on 2023-09-03 09:28:06
export PATH="$PATH:/Users/ryan/.local/bin"

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

