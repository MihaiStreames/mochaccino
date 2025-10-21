if not pgrep -u (id -u) ssh-agent > /dev/null
    eval (ssh-agent -c)
end

set -g fish_greeting

source ~/.config/fish/user.fish

# PATH
set -U fish_user_paths $HOME/.local/bin $fish_user_paths

set fish_pager_color_prefix cyan
set fish_color_autosuggestion brblack