import filecmp
import logging
from pathlib import Path
import shutil
from typing import TYPE_CHECKING

from config import HOME
from config import LOG_FILE
from config import Colors


if TYPE_CHECKING:
    from config import SyncConfig
    from ignore import IgnoreHandler


class FileSyncer:
    """Synchronizes files between source directories and target repository"""

    def __init__(
        self,
        sync_config: "SyncConfig",
        ignore_handler: "IgnoreHandler",
        dry_run: bool = False,
        verbose: bool = True,
    ):
        self.cfg = sync_config
        self._ignore_handler = ignore_handler
        self._dry_run = dry_run
        self._verbose = verbose
        self._processed_files: set[str] = set()

        logging.basicConfig(
            filename=LOG_FILE, level=logging.INFO, format="%(asctime)s - %(message)s"
        )
        self.logger = logging.getLogger("dotfiles_sync")

    def _log(self, action: str, message: str, color: str = "BLUE") -> None:
        """Log an action and optionally print to console"""
        if self._verbose:
            print(f"{Colors.colorize(f'[{action}]', color)} {message}")
        self.logger.info(f"[{action}] {message}")

    def _copy_if_needed(self, source: str, target: str, relative_path: str) -> None:
        """Copy file from source to target if needed, handling dry-run mode"""
        Path(target).parent.mkdir(parents=True, exist_ok=True)

        if self._dry_run:
            if not Path(target).exists():
                self._log("WOULD ADD", relative_path, "GREEN")
            elif not filecmp.cmp(source, target, shallow=False):
                self._log("WOULD UPDATE", relative_path, "YELLOW")
            return

        if not Path(target).exists():
            shutil.copy2(source, target)
            self._log("ADDED", relative_path, "GREEN")
        elif not filecmp.cmp(source, target, shallow=False):
            shutil.copy2(source, target)
            self._log("UPDATED", relative_path, "YELLOW")

    def sync_file(self, source_file: str | Path, base_dir: str | Path) -> None:
        """Sync a single file from source to target"""
        source_str = str(source_file)
        base_str = str(base_dir)

        # skip host-specific files, they're handled separately per host
        if source_str in self.cfg.host_specific_paths:
            if self._verbose:
                self._log("SKIP", f"{source_str} (host-specific)", "BLUE")
            return

        if source_str.startswith(HOME):
            relative_path = Path(source_str).relative_to(HOME)
        else:
            relative_path = (
                Path(source_str).relative_to(base_str)
                if Path(base_str).is_dir()
                else Path(Path(source_str).name)
            )

        if self._ignore_handler.should_ignore(source_str, base_str):
            self._log("IGNORED", str(relative_path), "BLUE")
            return

        self._processed_files.add(str(relative_path))
        target_file = self.cfg.target / relative_path
        self._copy_if_needed(source_str, str(target_file), str(relative_path))

    def process_directory(self, source_dir: str | Path) -> None:
        """Process a directory recursively and sync all files"""
        source_str = str(source_dir)
        base_dir = HOME if source_str.startswith(HOME) else str(Path(source_str).parent)

        for root, _, files in Path(source_str).walk():
            for file in files:
                path = root / file
                if path.is_file():
                    self.sync_file(path, base_dir)

    def sync_host_specific_file(self, source_file: str, relative_dest: str) -> None:
        """Sync a host-specific file to hosts/{host}/ inside the target"""
        if not Path(source_file).exists():
            if self._verbose:
                self._log("SKIP", f"{source_file} (doesn't exist)", "YELLOW")
            return

        host_relative_path = str(Path("hosts") / self.cfg.host / relative_dest)
        self._processed_files.add(host_relative_path)

        target_file = self.cfg.target / host_relative_path
        self._copy_if_needed(source_file, str(target_file), host_relative_path)

    def _cleanup_empty_dirs(self, directory: str) -> None:
        """Recursively remove empty directories"""
        dir_path = Path(directory)
        if not dir_path.is_dir() or dir_path == self.cfg.target:
            return

        if not any(dir_path.iterdir()):
            dir_path.rmdir()
            rel_dir = dir_path.relative_to(self.cfg.target)
            self._log("REMOVED", f"Empty directory: {rel_dir}", "RED")
            self._cleanup_empty_dirs(str(dir_path.parent))

    def detect_deleted_files(self, delete_mode: str = "ask") -> None:
        """Detect and optionally delete files that exist in target but not in source"""
        protected_files = [".gitignore", ".gitattributes", "README.md", "LICENSE"]
        # hosts/ is managed per-host, never treat other hosts' files as deleted
        hosts_dir = self.cfg.target / "hosts"

        if self._verbose:
            print(f"\n{Colors.colorize('Checking for deleted files...', 'BLUE')}")
        self.logger.info("Checking for deleted files...")

        for root, _, files in self.cfg.target.walk():
            for file in files:
                repo_file = root / file
                relative_path = repo_file.relative_to(self.cfg.target)

                if (
                    Path(relative_path).name in protected_files
                    or repo_file.is_relative_to(hosts_dir)
                    or self._ignore_handler.should_ignore(str(repo_file), str(self.cfg.target))
                    or str(relative_path) in self._processed_files
                ):
                    continue

                self._log("DELETED", str(relative_path), "RED")

                should_delete = False
                if delete_mode == "yes":
                    should_delete = True
                elif delete_mode == "ask":
                    choice = input("Delete this file from target? (y/n): ")
                    should_delete = choice.lower() in ("y", "yes")

                if self._dry_run:
                    if should_delete:
                        self._log("WOULD REMOVE", str(relative_path), "RED")
                    continue

                if should_delete:
                    repo_file.unlink()
                    self._log("REMOVED", f"{relative_path} from target", "RED")
                    self._cleanup_empty_dirs(str(repo_file.parent))
