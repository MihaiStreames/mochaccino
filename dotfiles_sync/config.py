import datetime
from pathlib import Path
from typing import Dict, List

SCRIPT_DIR = Path(__file__).parent.absolute()
TARGET_REPO: str = str(SCRIPT_DIR.parent)

HOME = str(Path.home())
SOURCE_DIRS: List[str] = [
    f"{HOME}/.config/kitty",
    f"{HOME}/.config/fish",
    f"{HOME}/.config/fastfetch",
    f"{HOME}/.config/hypr",
    f"{HOME}/.config/gtk-4.0",
    f"{HOME}/.config/gtk-3.0",
    f"{HOME}/.config/qt5ct",
    f"{HOME}/.config/qt6ct",
    f"{HOME}/.config/Kvantum",
    f"{HOME}/.config/wlogout",
    f"{HOME}/.config/dunst",
    f"{HOME}/.config/rofi",
    f"{HOME}/.config/waybar",
    f"{HOME}/.config/equibop/themes",
    f"{HOME}/.config/godot/editor_settings-4.5.tres",
    f"{HOME}/.config/godot/text_editor_themes",
    f"{HOME}/.config/Thunar/uca.xml",
    f"{HOME}/.config/sublime-text/Packages",
    f"{HOME}/.config/spicetify/Themes",
    f"{HOME}/.config/VSCodium/User/settings.json",
    f"{HOME}/.config/obs-studio/themes",
    f"{HOME}/.config/obs-studio/user.ini",
    f"{HOME}/.bash_profile",
    f"{HOME}/.bashrc",
    f"{HOME}/.nanorc",
    str(SCRIPT_DIR),
]


class Colors:
    GREEN  = "\033[0;32m"
    YELLOW = "\033[0;33m"
    RED    = "\033[0;31m"
    BLUE   = "\033[0;34m"
    PURPLE = "\033[0;35m"
    NC     = "\033[0m"

    @classmethod
    def colorize(cls, text: str, color: str) -> str:
        """Wrap text with color codes"""
        color_code = getattr(cls, color.upper(), cls.NC)
        return f"{color_code}{text}{cls.NC}"


timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
LOG_FILE = f"/tmp/dotfiles_sync_{timestamp}.log"

DEFAULT_SETTINGS: Dict[str, bool] = {
    "dry_run": False,
    "auto_delete": False,
    "verbose": True,
}
