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
alias cd..="cd.."
alias up="cd .."
alias gg="cd /Users/ryan/Git/"
alias r="ranger"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# Ark Compliance

ark() {
	cd ~/Git/ark-compliance;
	conda activate ark;
}

am() {
	git add --all;
	git commit --amend;
}

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


# Created by `pipx` on 2023-09-03 09:28:06
export PATH="$PATH:/Users/ryan/.local/bin"
