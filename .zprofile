# Brew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Asdf
. "$HOME/.asdf/asdf.sh"
fpath=(${ASDF_DIR}/completions $fpath)
autoload -Uz compinit && compinit
#

# Created by `pipx` on 2023-09-03 09:28:06
export PATH="$PATH:/Users/ryan/.local/bin"

# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
