if status is-interactive
# Commands to run in interactive sessions can go here
end

# pnpm
set -gx PNPM_HOME "/home/sincos/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# npm global
set -gx NPM_GLOBAL "/home/sincos/.npm-global/bin"
if not string match -q -- $NPM_GLOBAL $PATH
  set -gx PATH "$NPM_GLOBAL" $PATH
end
# npm global end
