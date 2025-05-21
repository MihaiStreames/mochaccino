import datetime
from pathlib import Path
from typing import Dict, List

SCRIPT_DIR = Path(__file__).parent.absolute()
TARGET_REPO: str = str(SCRIPT_DIR.parent)

HOME = str(Path.home())
SOURCE_DIRS: List[str] = [
    f"{HOME}/.config/alacritty",
    f"{HOME}/.config/fish",
    f"{HOME}/.config/hypr",
    f"{HOME}/.config/mako",
    f"{HOME}/.config/qt5ct",
    f"{HOME}/.config/qt6ct",
    f"{HOME}/.config/rofi",
    f"{HOME}/.config/wal",
    f"{HOME}/.config/waybar",
    f"{HOME}/.config/zathura",
    f"{HOME}/.themes/oomox-MihuuTheme",
    f"{HOME}/.themes/ide-MihuuThemes",
    f"{HOME}/.bash_profile",
    f"{HOME}/.bashrc",
    f"{HOME}/.nanorc",
    str(SCRIPT_DIR)
]


class Colors:
    GREEN = '\033[0;32m'
    YELLOW = '\033[0;33m'
    RED = '\033[0;31m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    NC = '\033[0m'

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
    "verbose": True
}
