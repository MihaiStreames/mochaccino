from datetime import datetime
from pathlib import Path


SCRIPT_DIR = Path(__file__).parent.absolute()
TARGET_REPO = str(SCRIPT_DIR.parent)
HOME = str(Path.home())

HOST_TYPE = "pc"

COMMON_DIRS: list[str] = [
    f"{HOME}/.config/hypr",
    f"{HOME}/.config/kitty",
    f"{HOME}/.config/fish",
    f"{HOME}/.config/fastfetch",
    f"{HOME}/.config/gtk-4.0",
    f"{HOME}/.config/gtk-3.0",
    f"{HOME}/.config/qt5ct",
    f"{HOME}/.config/qt6ct",
    f"{HOME}/.config/Kvantum",
    f"{HOME}/.config/wlogout",
    f"{HOME}/.config/dunst",
    f"{HOME}/.config/rofi",
    f"{HOME}/.config/waybar",
    f"{HOME}/.config/Thunar/uca.xml",
    f"{HOME}/.config/equibop/themes",
    f"{HOME}/.config/godot/editor_settings-4.5.tres",
    f"{HOME}/.config/godot/text_editor_themes",
    f"{HOME}/.config/sublime-text/Packages",
    f"{HOME}/.config/spicetify/Themes",
    f"{HOME}/.config/Code/User/settings.json",
    f"{HOME}/.config/obs-studio/themes",
    f"{HOME}/.config/obs-studio/user.ini",
    f"{HOME}/.bash_profile",
    f"{HOME}/.bashrc",
    f"{HOME}/.nanorc",
    str(SCRIPT_DIR),
]

HOST_SPECIFIC_FILES: list[tuple[str, str]] = [
    (f"{HOME}/.config/hypr/conf/monitors.conf", "hypr/conf/monitors.conf"),
    (f"{HOME}/.config/hypr/conf/keybinds.conf", "hypr/conf/keybinds.conf"),
    (f"{HOME}/.config/hypr/conf/monitors.conf", "hypr/conf/monitors.conf"),
    (f"{HOME}/.config/hypr/conf/env.conf", "hypr/conf/env.conf"),
    (f"{HOME}/.config/hypr/hypridle.conf", "hypr/hypridle.conf"),
    (f"{HOME}/.config/gtk-3.0/bookmarks", "gtk-3.0/bookmarks"),
]

HOST_SPECIFIC_PATHS = {path for path, _ in HOST_SPECIFIC_FILES}


class Colors:
    """ANSI color codes for terminal output"""

    GREEN = "\033[0;32m"
    YELLOW = "\033[0;33m"
    RED = "\033[0;31m"
    BLUE = "\033[0;34m"
    PURPLE = "\033[0;35m"
    NC = "\033[0m"

    @classmethod
    def colorize(cls, text: str, color: str) -> str:
        """Wrap text with color codes"""
        color_code = getattr(cls, color.upper(), cls.NC)
        return f"{color_code}{text}{cls.NC}"


LOG_FILE = f"/tmp/dotfiles_sync_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"

DEFAULT_SETTINGS: dict[str, bool] = {
    "dry_run": False,
    "auto_delete": False,
    "verbose": True,
}
