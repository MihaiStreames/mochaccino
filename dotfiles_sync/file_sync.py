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

    def _calculate_relative_path(self, source_path: str, target_category: str) -> str:
        """Calculate the relative path within the target category folder."""
        source_path_obj = Path(source_path)

        # For files directly in HOME (like .bashrc)
        if source_path_obj.parent == Path(HOME):
            return source_path_obj.name

        # For paths under .config
        if ".config" in source_path:
            config_path = Path(HOME) / ".config"
            try:
                relative = source_path_obj.relative_to(config_path)
                return str(relative)
            except ValueError:
                pass

        # For paths under .local
        if ".local" in source_path:
            local_path = Path(HOME) / ".local"
            try:
                relative = source_path_obj.relative_to(local_path)
                return str(relative)
            except ValueError:
                pass

        # Default: use the basename for single files, or relative path from HOME
        try:
            relative = source_path_obj.relative_to(Path(HOME))
            return str(relative)
        except ValueError:
            return source_path_obj.name

    def sync_file(self, source_file: Union[str, Path], target_category: str, base_source_path: str) -> None:
        """Sync a single file from source to target repo under the appropriate category."""
        source_file_str = str(source_file)
        base_source_obj = Path(base_source_path)
        source_file_obj = Path(source_file_str)

        # Determine the relative path based on whether base_source is a file or directory
        if base_source_obj.is_file():
            # For single file mappings, preserve the directory structure relative to HOME
            # Example: ~/.config/Code/User/settings.json -> .config/Code/User/settings.json
            try:
                relative_to_home = source_file_obj.relative_to(Path(HOME))
                # Remove the leading home-relative part (like .config/) to get the rest
                parts = relative_to_home.parts
                if parts[0] == '.config':
                    # Keep everything after .config
                    relative_path = str(Path(*parts[1:])) if len(parts) > 1 else parts[0]
                elif parts[0] == '.local':
                    # Keep everything after .local
                    relative_path = str(Path(*parts[1:])) if len(parts) > 1 else parts[0]
                else:
                    # For home directory files like .bashrc, just use the filename
                    relative_path = source_file_obj.name
            except ValueError:
                relative_path = source_file_obj.name
        else:
            # For directory mappings, preserve structure relative to the parent of the base directory
            # Example: ~/.config/kitty/file.conf -> kitty/file.conf
            try:
                # Get the base directory name (e.g., 'kitty' from ~/.config/kitty)
                base_name = base_source_obj.name
                # Get path relative to base source directory
                relative_to_base = source_file_obj.relative_to(base_source_obj)
                # Combine base name with relative path
                relative_path = str(Path(base_name) / relative_to_base)
            except ValueError:
                relative_path = source_file_obj.name

        # Build target path: repo/target_category/relative_path
        target_file = os.path.join(TARGET_REPO, target_category, relative_path)

        # Check if file should be ignored
        if self.gitignore_handler.should_ignore(source_file_str, os.path.dirname(source_file_str)):
            self._log_and_print('IGNORED', f"{target_category}/{relative_path}", 'BLUE')
            return

        # Add to processed files (with category prefix)
        self.processed_files.add(os.path.join(target_category, relative_path))

        # Create target directory if it doesn't exist
        os.makedirs(os.path.dirname(target_file), exist_ok=True)

        # Check if this is a dry run
        if self.settings['dry_run']:
            if not os.path.exists(target_file):
                self._log_and_print('WOULD ADD', f"{target_category}/{relative_path}", 'GREEN')
            elif not filecmp.cmp(source_file_str, target_file, shallow=False):
                self._log_and_print('WOULD UPDATE', f"{target_category}/{relative_path}", 'YELLOW')
            return

        if not os.path.exists(target_file):
            # File doesn't exist in target, copy it
            shutil.copy2(source_file_str, target_file)
            self._log_and_print('ADDED', f"{target_category}/{relative_path}", 'GREEN')
        elif not filecmp.cmp(source_file_str, target_file, shallow=False):
            # File exists but is different, update it
            shutil.copy2(source_file_str, target_file)
            self._log_and_print('UPDATED', f"{target_category}/{relative_path}", 'YELLOW')

    def process_source(self, source_path: Union[str, Path], target_category: str) -> None:
        """Process a source (file or directory) and sync to target category."""
        source_path_str = str(source_path)

        if os.path.isfile(source_path_str):
            # Single file
            self.sync_file(source_path_str, target_category, source_path_str)
        elif os.path.isdir(source_path_str):
            # Directory - walk through it
            for root, _, files in os.walk(source_path_str):
                for file in files:
                    full_path = os.path.join(root, file)
                    self.sync_file(full_path, target_category, source_path_str)

    def detect_deleted_files(self, delete_mode: str = "ask") -> None:
        """Detect files that exist in repo but not in source."""
        protected_files = [".gitignore", ".gitattributes", "README.md", "LICENSE"]
        protected_dirs = ["dotfiles_sync", ".git"]

        if self.settings['verbose']:
            print(f"\n{Colors.colorize('Checking for deleted files...', 'BLUE')}")

        self.logger.info("Checking for deleted files...")

        # Walk through all files in the repo
        for root, dirs, files in os.walk(TARGET_REPO):
            # Skip protected directories
            dirs[:] = [d for d in dirs if d not in protected_dirs]

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
