# Aliases
alias c='clear'

alias l='eza -lh --icons=auto'
alias ls='eza -1 --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lt='eza --icons=auto --tree'

alias grep='grep --color=auto'

alias neofetch='fastfetch'
alias fetch='fastfetch'

alias lss='du -ah --max-depth 1'

alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

alias waybar-reload='pkill waybar && hyprctl dispatch exec waybar'

alias zmap='xhost +SI:localuser:root && pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY zenmap && xhost -SI:localuser:root'
alias link-cleaner='python ~/.config/fish/scripts/link-cleaner.py'
