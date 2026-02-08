#  ██████╗ ██████╗ ██╗      ██████╗ ██████╗ ███████╗
# ██╔════╝██╔═══██╗██║     ██╔═══██╗██╔══██╗██╔════╝
# ██║     ██║   ██║██║     ██║   ██║██████╔╝███████╗
# ██║     ██║   ██║██║     ██║   ██║██╔══██╗╚════██║
# ╚██████╗╚██████╔╝███████╗╚██████╔╝██║  ██║███████║
#  ╚═════╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

set -U fish_color_normal {{ mochaccino.color7.default.hex_stripped }}
set -U fish_color_command {{ mochaccino.color4.default.hex_stripped }}
set -U fish_color_param {{ colors.secondary.default.hex_stripped }}
set -U fish_color_keyword {{ mochaccino.color1.default.hex_stripped }}
set -U fish_color_quote {{ mochaccino.color2.default.hex_stripped }}
set -U fish_color_redirection {{ mochaccino.color5.default.hex_stripped }}
set -U fish_color_end {{ mochaccino.color3.default.hex_stripped }}
set -U fish_color_comment {{ mochaccino.color8.default.hex_stripped }}
set -U fish_color_error {{ colors.error.default.hex_stripped }}
set -U fish_color_gray {{ colors.outline_variant.default.hex_stripped }}
set -U fish_color_selection --background={{ colors.surface_container.default.hex_stripped }}
set -U fish_color_search_match --background={{ colors.surface_container.default.hex_stripped }}
set -U fish_color_option {{ mochaccino.color2.default.hex_stripped }}
set -U fish_color_operator {{ mochaccino.color5.default.hex_stripped }}
set -U fish_color_escape {{ mochaccino.color9.default.hex_stripped }}
set -U fish_color_autosuggestion {{ colors.outline_variant.default.hex_stripped }}
set -U fish_color_cancel {{ mochaccino.color1.default.hex_stripped }}
set -U fish_color_cwd {{ mochaccino.color3.default.hex_stripped }}
set -U fish_color_user {{ mochaccino.color6.default.hex_stripped }}
set -U fish_color_host {{ mochaccino.color4.default.hex_stripped }}
set -U fish_color_host_remote {{ mochaccino.color2.default.hex_stripped }}
set -U fish_color_status {{ mochaccino.color1.default.hex_stripped }}
set -U fish_pager_color_progress {{ colors.outline_variant.default.hex_stripped }}
set -U fish_pager_color_prefix {{ mochaccino.color6.default.hex_stripped }}
set -U fish_pager_color_completion {{ mochaccino.color7.default.hex_stripped }}
set -U fish_pager_color_description {{ colors.outline_variant.default.hex_stripped }}
