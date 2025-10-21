import filecmp
import logging
import os
import shutil
from pathlib import Path
from typing import Set, Union, Optional, Dict

from config import Colors, LOG_FILE, TARGET_REPO, DEFAULT_SETTINGS, HOME


class FileSyncer:
    """Synchronizes files between source directories and target repository."""

    def __init__(self, gitignore_handler, settings: Optional[Dict[str, bool]] = None):
        """Initialize the FileSyncer with gitignore handler and optional settings."""
        self.gitignore_handler = gitignore_handler
        self.processed_files: Set[str] = set()
        self.settings = DEFAULT_SETTINGS.copy()

        # Update settings if provided
        if settings:
            self.settings.update(settings)

        # Set up logging
        logging.basicConfig(
            filename=LOG_FILE,
            level=logging.INFO,
            format='%(asctime)s - %(message)s'
        )
        self.logger = logging.getLogger('dotfiles_sync')

    def _log_and_print(self, action: str, message: str, color: str = 'BLUE') -> None:
        """Log an action and print it to console with color."""
        if self.settings['verbose']:
            colored_msg = f"{Colors.colorize(f'[{action}]', color)} {message}"
            print(colored_msg)

        self.logger.info(f"[{action}] {message}")

    def sync_file(self, source_file: Union[str, Path], base_dir: Union[str, Path]) -> None:
        """Sync a single file from source to target repo."""
        # Convert paths to strings
        source_file_str = str(source_file)
        base_dir_str = str(base_dir)

        # Calculate relative path from HOME to preserve full structure
        if source_file_str.startswith(HOME):
            # For files under HOME, preserve the path structure relative to HOME
            relative_path = os.path.relpath(source_file_str, HOME)
        else:
            # For other files, use the base_dir approach
            if os.path.isdir(base_dir_str):
                relative_path = os.path.relpath(source_file_str, base_dir_str)
            else:
                relative_path = os.path.basename(source_file_str)

        target_file = os.path.join(TARGET_REPO, relative_path)

        # Check if file should be ignored
        if self.gitignore_handler.should_ignore(source_file_str, base_dir_str):
            self._log_and_print('IGNORED', relative_path, 'BLUE')
            return

        # Add to processed files
        self.processed_files.add(relative_path)

        # Create target directory if it doesn't exist
        os.makedirs(os.path.dirname(target_file), exist_ok=True)

        # Check if this is a dry run
        if self.settings['dry_run']:
            if not os.path.exists(target_file):
                self._log_and_print('WOULD ADD', relative_path, 'GREEN')
            elif not filecmp.cmp(source_file_str, target_file, shallow=False):
                self._log_and_print('WOULD UPDATE', relative_path, 'YELLOW')
            return

        if not os.path.exists(target_file):
            # File doesn't exist in target, copy it
            shutil.copy2(source_file_str, target_file)
            self._log_and_print('ADDED', relative_path, 'GREEN')
        elif not filecmp.cmp(source_file_str, target_file, shallow=False):
            # File exists but is different, update it
            shutil.copy2(source_file_str, target_file)
            self._log_and_print('UPDATED', relative_path, 'YELLOW')

    def process_directory(self, source_dir: Union[str, Path]) -> None:
        """Process a directory recursively and sync all files."""
        source_dir_str = str(source_dir)
        # Use HOME as base_dir to preserve full structure
        base_dir = HOME if source_dir_str.startswith(HOME) else os.path.dirname(source_dir_str)

        for root, _, files in os.walk(source_dir_str):
            # Process files in current directory
            for file in files:
                full_path = os.path.join(root, file)
                self.sync_file(full_path, base_dir)

    def detect_deleted_files(self, delete_mode: str = "ask") -> None:
        """Detect files that exist in repo but not in source."""
        # To never delete !
        protected_files = [".gitignore", ".gitattributes", "README.md", "LICENSE"]

        if self.settings['verbose']:
            print(f"\n{Colors.colorize('Checking for deleted files...', 'BLUE')}")

        self.logger.info("Checking for deleted files...")

        # Walk through all files in the repo
        for root, _, files in os.walk(TARGET_REPO):
            for file in files:
                repo_file = os.path.join(root, file)
                relative_path = os.path.relpath(repo_file, TARGET_REPO)

                # Skip protected files
                if os.path.basename(relative_path) in protected_files:
                    continue

                # Skip if file should be ignored
                if self.gitignore_handler.should_ignore(repo_file, TARGET_REPO):
                    continue

                # Check if this file was processed (exists in source)
                if relative_path not in self.processed_files:
                    self._log_and_print('DELETED', relative_path, 'RED')

                    # Determine whether to delete file
                    delete_file = False
                    if delete_mode == "yes":
                        delete_file = True
                    elif delete_mode == "ask":
                        choice = input("Delete this file from repo? (y/n): ")
                        delete_file = choice.lower() in ('y', 'yes')

                    if self.settings['dry_run']:
                        if delete_file:
                            self._log_and_print('WOULD REMOVE', relative_path, 'RED')
                        continue

                    if delete_file:
                        # Delete the file
                        os.remove(repo_file)
                        self._log_and_print('REMOVED', f"{relative_path} from repo", 'RED')

                        # Check if directory is now empty and remove if it is
                        self._cleanup_empty_dirs(os.path.dirname(repo_file))

    def _cleanup_empty_dirs(self, directory: str) -> None:
        """Recursively remove empty directories."""
        if not os.path.isdir(directory) or directory == TARGET_REPO:
            return

        if not os.listdir(directory):
            os.rmdir(directory)
            rel_dir = os.path.relpath(directory, TARGET_REPO)
            self._log_and_print('REMOVED', f"Empty directory: {rel_dir}", 'RED')

            # Check if parent is now empty
            self._cleanup_empty_dirs(os.path.dirname(directory))
