#!/usr/bin/zsh
# Common Directories
setopt cdablevars
hash -d Projects="$HOME/Projects" 
hash -d Dl="$HOME/Downloads" 
hash -d cfg="$HOME/.config"
hash -d qconf=~cfg/qtile
hash -d Maintenance="$HOME/Documents/Maintenance"
hash -d WeekMaint="$HOME/Documents/Maintenance/Weekly"
hash -d Uni=$HOME/Documents/Uni

# Quickly edit .config files
function conf {
	# Config file names
	typeset -A configs=(
		'qtile'							'config.py'
		'qtile/hooks'				'hooks.py'
		'qtile/keys'				'keybindings.py'
		'rofi'							'config.rasi'
		'nvim'							'init.lua'
		'nvim/plugins'			'lua/plugins/a'
		'zsh'								'.zshrc'
		'zsh/alias'					'aliases.zsh'
		'alacritty'					'alacritty.toml'
		'eww'								'eww.yuck'
		'eww/style'					'eww.scss'
		'hypr'							'hyprland.conf'
		'hypr/keys'					'hyprland_keybindings.conf'
	)
	confargs=(${(@s:/:)1})
	# Checks if there is a config file declared
	if [ "${configs[$1]+isset}" ]
	then
		nvim ~cfg/$confargs[1]/$configs[$1]
	elif [ -f ~cfg/$confargs[1]/$confargs[2] ]
	then
		nvim ~cfg/$confargs[1]/$confargs[2]
	elif [ -d ~cfg/$confargs[1] ]
	then
		# Just open the config folder
		nvim ~cfg/$1
	else
		mkdir ~cfg/$confargs[1]
		nvim ~cfg/$confargs[1]
		if [ ! $(ls -A ~cfg/$confargs[1]) ]
		then
			rm -r ~cfg/$confargs[1]
		fi
	fi
}

alias sudo="sudo "
alias s="sudo "
alias ls="exa --icons=auto"
alias l="exa -lh --color-scale --color-scale-mode=gradient"
alias la="exa -lah --color-scale --color-scale-mode=gradient"
# Package management
alias -g i="install"
alias -g Rm="remove"
alias -g sea="search"

## Apt
alias sa="sudo apt " 
alias sagi="sudo apt install " 
alias sagu="sudo apt remove " 

## Dnf
alias sd="sudo dnf "

## Pip
alias p="python -m pip"

alias cleat="clear"
alias c="clear"
alias claer="clear"
alias cd="z"
alias v="nvim"
alias vim="nvim"
alias zf="zathura --fork"
alias py="python"
alias ipy="python -m IPython"
alias edge="microsoft-edge-dev"
alias swaylock="swaylock-effects"
# alias zshconfig="mate ~/.zshrc"
alias dot-cfg='/usr/bin/git --git-dir=/home/azule/.dotfiles/ --work-tree=/home/azule'
# alias ohmyzsh="mate ~/.oh-my-zsh"
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey -v
bindkey "^k" up-line-or-beginning-search # Up
bindkey "^j" down-line-or-beginning-search # Down
bindkey "^?" backward-delete-char
bindkey '^ ' autosuggest-accept
bindkey "^l" autosuggest-execute
