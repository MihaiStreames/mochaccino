import filecmp
import logging
import os
from pathlib import Path
import shutil
from typing import TYPE_CHECKING

from config import DEFAULT_SETTINGS
from config import HOME
from config import HOST_SPECIFIC_PATHS
from config import HOST_TYPE
from config import LOG_FILE
from config import TARGET_REPO
from config import Colors


if TYPE_CHECKING:
    from gitignore import GitIgnoreHandler


class FileSyncer:
    """Synchronizes files between source directories and target repository"""

    def __init__(
        self, gitignore_handler: GitIgnoreHandler, settings: dict[str, bool] | None = None
    ):
        self.gitignore_handler = gitignore_handler
        self.processed_files: set[str] = set()
        self.settings = DEFAULT_SETTINGS.copy()

        if settings:
            self.settings.update(settings)

        # Setup logging
        logging.basicConfig(
            filename=LOG_FILE, level=logging.INFO, format="%(asctime)s - %(message)s"
        )
        self.logger = logging.getLogger("dotfiles_sync")

    def _log(self, action: str, message: str, color: str = "BLUE") -> None:
        """Log an action and optionally print to console"""
        if self.settings["verbose"]:
            print(f"{Colors.colorize(f'[{action}]', color)} {message}")
        self.logger.info(f"[{action}] {message}")

    def _copy_if_needed(self, source: str, target: str, relative_path: str) -> None:
        """Copy file from source to target if needed, handling dry-run mode"""
        os.makedirs(os.path.dirname(target), exist_ok=True)

        if self.settings["dry_run"]:
            if not os.path.exists(target):
                self._log("WOULD ADD", relative_path, "GREEN")
            elif not filecmp.cmp(source, target, shallow=False):
                self._log("WOULD UPDATE", relative_path, "YELLOW")
            return

        if not os.path.exists(target):
            shutil.copy2(source, target)
            self._log("ADDED", relative_path, "GREEN")
        elif not filecmp.cmp(source, target, shallow=False):
            shutil.copy2(source, target)
            self._log("UPDATED", relative_path, "YELLOW")

    def sync_file(self, source_file: str | Path, base_dir: str | Path) -> None:
        """Sync a single file from source to target repo"""
        source_str = str(source_file)
        base_str = str(base_dir)

        # Skip host-specific files
        if source_str in HOST_SPECIFIC_PATHS:
            if self.settings["verbose"]:
                self._log("SKIP", f"{source_str} (host-specific)", "BLUE")
            return

        # Calculate relative path
        if source_str.startswith(HOME):
            relative_path = os.path.relpath(source_str, HOME)
        else:
            relative_path = (
                os.path.relpath(source_str, base_str)
                if os.path.isdir(base_str)
                else os.path.basename(source_str)
            )

        # Check if file should be ignored
        if self.gitignore_handler.should_ignore(source_str, base_str):
            self._log("IGNORED", relative_path, "BLUE")
            return

        self.processed_files.add(relative_path)
        target_file = os.path.join(TARGET_REPO, relative_path)
        self._copy_if_needed(source_str, target_file, relative_path)

    def process_directory(self, source_dir: str | Path) -> None:
        """Process a directory recursively and sync all files"""
        source_str = str(source_dir)
        base_dir = HOME if source_str.startswith(HOME) else os.path.dirname(source_str)

        for root, _, files in os.walk(source_str):
            for file in files:
                self.sync_file(os.path.join(root, file), base_dir)

    def sync_host_specific_file(self, source_file: str, relative_dest: str) -> None:
        """Sync a host-specific file to hosts/{pc|laptop}/ directory"""
        if not os.path.exists(source_file):
            if self.settings["verbose"]:
                self._log("SKIP", f"{source_file} (doesn't exist)", "YELLOW")
            return

        host_relative_path = os.path.join("hosts", HOST_TYPE, relative_dest)
        self.processed_files.add(host_relative_path)

        target_file = os.path.join(TARGET_REPO, host_relative_path)
        self._copy_if_needed(source_file, target_file, host_relative_path)

    def _cleanup_empty_dirs(self, directory: str) -> None:
        """Recursively remove empty directories"""
        if not os.path.isdir(directory) or directory == TARGET_REPO:
            return

        if not os.listdir(directory):
            os.rmdir(directory)
            rel_dir = os.path.relpath(directory, TARGET_REPO)
            self._log("REMOVED", f"Empty directory: {rel_dir}", "RED")
            self._cleanup_empty_dirs(os.path.dirname(directory))

    def detect_deleted_files(self, delete_mode: str = "ask") -> None:
        """Detect and optionally delete files that exist in repo but not in source"""
        protected_files = [".gitignore", ".gitattributes", "README.md", "LICENSE"]

        if self.settings["verbose"]:
            print(f"\n{Colors.colorize('Checking for deleted files...', 'BLUE')}")
        self.logger.info("Checking for deleted files...")

        for root, _, files in os.walk(TARGET_REPO):
            for file in files:
                repo_file = os.path.join(root, file)
                relative_path = os.path.relpath(repo_file, TARGET_REPO)

                # Skip protected and ignored files
                if (
                    os.path.basename(relative_path) in protected_files
                    or self.gitignore_handler.should_ignore(repo_file, TARGET_REPO)
                    or relative_path in self.processed_files
                ):
                    continue

                self._log("DELETED", relative_path, "RED")

                # Determine if file should be deleted
                should_delete = False
                if delete_mode == "yes":
                    should_delete = True
                elif delete_mode == "ask":
                    choice = input("Delete this file from repo? (y/n): ")
                    should_delete = choice.lower() in ("y", "yes")

                if self.settings["dry_run"]:
                    if should_delete:
                        self._log("WOULD REMOVE", relative_path, "RED")
                    continue

                if should_delete:
                    os.remove(repo_file)
                    self._log("REMOVED", f"{relative_path} from repo", "RED")
                    self._cleanup_empty_dirs(os.path.dirname(repo_file))
