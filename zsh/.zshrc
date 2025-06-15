if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
source ~/.zplug/init.zsh
ZSH_CUSTOM=$HOME/.config/zsh
# ZSH_THEME="powerlevel10k/powerlevel10k"
source $ZSH_CUSTOM/aliases.zsh
# source ~/.zplug/init.zsh
# ZSH_THEME="random"
# source $ZDOTDIR/.antidote/antidote.zsh
# antidote load
# plugins=(
# 	zsh-syntax-highlighting
# 	last-working-dir
# 	frontend-search
# 	fzf-tab
# 	zsh-autosuggestions
# )
eval "$(oh-my-posh init zsh --config $HOME/.config/oh-my-posh/config.omp.toml)"
eval "$(zoxide init zsh)"
export EDITOR="nvim"

fpath+=$HOME/.config/zsh/.zfunc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
autoload -Uz compinit
compinit

compdef _gnu_generic fzf

zplug "zsh-users/zsh-syntax-highlighting"
# zplug "MenkeTechnologies/zsh-cargo-completion"
zplug "plugins/git", from:oh-my-zsh
# zplug "plugins/rust", from:oh-my-zsh
zplug "plugins/last-working-dir", from:oh-my-zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "Aloxaf/fzf-tab"
# zsh parameter completion for the dotnet CLI

_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")

  # If the completion list is empty, just continue with filename selection
  if [ -z "$completions" ]
  then
    _arguments '*::arguments: _normal'
    return
  fi

  # This is not a variable assignment, don't remove spaces!
  _values = "${(ps:\n:)completions}"
}

compdef _dotnet_zsh_complete dotnet
# zplug "memark/zsh-dotnet-completion", defer:2
# zplug "pjvds/zsh-cwd", hook-load:"cwd"

if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# zplug load --verbose
zplug load

HYPHEN_INSENSITIVE="true"

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*' menu select

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory


. "$HOME/.local/share/../bin/env"
