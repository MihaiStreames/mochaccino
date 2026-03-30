from datetime import datetime
from pathlib import Path
import tomllib


SCRIPT_DIR = Path(__file__).parent.absolute()
REPO_ROOT = SCRIPT_DIR.parent
HOME = str(Path.home())

_TOML_PATH = SCRIPT_DIR / "sync.toml"


def _expand(path: str) -> str:
    return str(Path(path).expanduser())


class SyncConfig:
    def __init__(
        self,
        host: str,
        target: Path,
        sync_ignore: list[str],
        common_dirs: list[str],
        host_files: list[tuple[str, str]],
        host_specific_paths: set[str],
    ) -> None:
        self.host = host
        self.target = target
        self.sync_ignore = sync_ignore
        self.common_dirs = common_dirs
        self.host_files = host_files
        self.host_specific_paths = host_specific_paths


def load_config(
    host_override: str | None = None,
    target_override: str | None = None,
) -> "SyncConfig":
    with _TOML_PATH.open("rb") as f:
        data = tomllib.load(f)

    host = host_override or data.get("host", "")
    if not host:
        raise ValueError("No host set — use --host or set 'host' in sync.toml")

    raw_target = target_override or data.get("target", "dotfiles")
    target = (REPO_ROOT / raw_target).resolve()
    if not target.exists():
        target.mkdir(parents=True)

    ignore: list[str] = data.get("sync", {}).get("ignore", [])
    common_dirs: list[str] = [_expand(p) for p in data.get("common", {}).get("dirs", [])]

    hosts = data.get("hosts", {})
    if host not in hosts:
        raise ValueError(f"Unknown host '{host}' — add it to sync.toml under [hosts.{host}]")

    host_files: list[tuple[str, str]] = [
        (_expand(src), dest) for src, dest in hosts[host].get("files", [])
    ]
    host_specific_paths = {src for src, _ in host_files}

    return SyncConfig(
        host=host,
        target=target,
        sync_ignore=ignore,
        common_dirs=common_dirs,
        host_files=host_files,
        host_specific_paths=host_specific_paths,
    )


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
