# ██╗███╗   ██╗██╗████████╗
# ██║████╗  ██║██║╚══██╔══╝
# ██║██╔██╗ ██║██║   ██║
# ██║██║╚██╗██║██║   ██║
# ██║██║ ╚████║██║   ██║
# ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝

# SSH Agent
if not pgrep -u (id -u) ssh-agent > /dev/null
    eval (ssh-agent -c)
end

# Disable greeting
set -g fish_greeting
