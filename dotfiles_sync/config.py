import datetime
from pathlib import Path
from typing import Dict, List, Tuple

SCRIPT_DIR = Path(__file__).parent.absolute()
TARGET_REPO: str = str(SCRIPT_DIR.parent)

HOME = str(Path.home())

SOURCE_MAPPINGS: List[Tuple[str, str]] = [
    (f"{HOME}/.config/kitty", ".config"),
    (f"{HOME}/.config/fish", ".config"),
    (f"{HOME}/.config/fastfetch", ".config"),
    (f"{HOME}/.config/hypr", ".config"),
    (f"{HOME}/.config/gtk-4.0", ".config"),
    (f"{HOME}/.config/gtk-3.0", ".config"),
    (f"{HOME}/.config/qt5ct", ".config"),
    (f"{HOME}/.config/qt6ct", ".config"),
    (f"{HOME}/.config/Kvantum", ".config"),
    (f"{HOME}/.config/wlogout", ".config"),
    (f"{HOME}/.config/dunst", ".config"),
    (f"{HOME}/.config/rofi", ".config"),
    (f"{HOME}/.config/waybar", ".config"),
    (f"{HOME}/.config/Code/User/settings.json", ".config"),
    (f"{HOME}/.bash_profile", ".home"),
    (f"{HOME}/.bashrc", ".home"),
    (f"{HOME}/.nanorc", ".home")
    # (str(SCRIPT_DIR), ".scripts")
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
