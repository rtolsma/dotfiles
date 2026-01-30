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
# API keys loaded from ~/.secrets
[ -f ~/.secrets ] && source ~/.secrets


# Path finalizers
# Asdf
. "$HOME/.asdf/asdf.sh"
# Rye
. "$HOME/.rye/env"
# Cargo
. "$HOME/.cargo/env"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/ryan/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/ryan/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/ryan/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/ryan/google-cloud-sdk/completion.zsh.inc'; fi

# gemini -- key in ~/.secrets

# Browser-Use
export ANONYMIZED_TELEMETRY=false

# export DYLD_LIBRARY_PATH="/opt/homebrew/lib:$DYLD_LIBRARY_PATH"
unset DYLD_LIBRARY_PATH


# Lux Computer Use -- keys in ~/.secrets

# bun completions
[ -s "/Users/ryan/.bun/_bun" ] && source "/Users/ryan/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

