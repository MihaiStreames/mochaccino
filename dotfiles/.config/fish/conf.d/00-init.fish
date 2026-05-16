### SSH AGENT ###

if not pgrep -u (id -u) ssh-agent > /dev/null
  eval (ssh-agent -c)
end

set -g fish_greeting
