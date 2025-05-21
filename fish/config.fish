if not pgrep -u (id -u) ssh-agent > /dev/null
    eval (ssh-agent -c)
end

if status is-interactive
    set fish_greeting
end

# Path
set -U fish_user_paths $HOME/.local/bin $fish_user_paths
set -Ux QT_QPA_PLATFORM xcb

# Qt
export QT_QPA_PLATFORMTHEME=qt5ct
export QT6CT_PLATFORMTHEME=qt6ct
# export QT_STYLE_OVERRIDE=kvantum

# Aliases
alias vim=nvim
alias ls='ls --color=auto'
alias ll='ls -alh --color=auto'
alias grep='grep --color=auto'
alias neofetch='fastfetch'
alias fetch='fastfetch'
alias lss='du -ah --max-depth 1'
alias waybar-reload='pkill waybar && hyprctl dispatch exec waybar'

# Colors
set fish_color_autosuggestion 616277
set fish_color_cancel 2d324e '--reverse'
set fish_color_command 4D4A72
set fish_color_comment 616277
set fish_color_cwd 393755
set fish_color_cwd_root 2d324e
set fish_color_end 6f4a57
set fish_color_error 2d324e
set fish_color_escape 392f84
set fish_color_history_current --bold
set fish_color_host 622F9A
set fish_color_host_remote 622F9A
set fish_color_keyword 392f84
set fish_color_match --background=492373
set fish_color_normal c3c3ca
set fish_color_operator 3f3b71
set fish_color_option 6f4a57
set fish_color_param 622F9A
set fish_color_quote 956375
set fish_color_redirection 392f84
set fish_color_search_match --background=616277
set fish_color_selection --background=616277
set fish_color_status 2d324e
set fish_color_user 4D4A72
set fish_color_valid_path --underline

set fish_pager_color_background 0F122D
set fish_pager_color_completion c3c3ca
set fish_pager_color_description 616277
set fish_pager_color_prefix 4D4A72
set fish_pager_color_progress 616277
set fish_pager_color_secondary_background 0F122D
set fish_pager_color_secondary_completion c3c3ca
set fish_pager_color_secondary_description 616277
set fish_pager_color_secondary_prefix 4D4A72
set fish_pager_color_selected_background --background=616277
set fish_pager_color_selected_completion c3c3ca
set fish_pager_color_selected_description 616277
set fish_pager_color_selected_prefix 4D4A72
