"""
(Dot)files Synchronization Tool
Author: MihuuStrames (2025)
Simple utility to sync (dot)files between source directories and a git repository.

Usage:
    python main.py [options]

Options:
    --dry-run    - Show what would be done without making changes
    --auto-del   - Automatically delete files that don't exist in source
    --quiet      - Reduce verbosity of output
"""

import argparse
import os
import sys
import traceback
from typing import Dict

from config import LOG_FILE, SOURCE_DIRS, TARGET_REPO, Colors
from file_sync import FileSyncer
from gitignore import GitIgnoreHandler


def parse_args() -> Dict[str, bool]:
    """Parse command line arguments and return settings dictionary"""
    parser = argparse.ArgumentParser(
        description="Synchronize dotfiles between source directories and target repository"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be done without making changes",
    )
    parser.add_argument(
        "--auto-del",
        action="store_true",
        help="Automatically delete files from repo that no longer exist in source",
    )
    parser.add_argument(
        "--quiet", action="store_true", help="Reduce verbosity of output"
    )

    args = parser.parse_args()

    return {
        "dry_run": args.dry_run,
        "auto_delete": args.auto_del,
        "verbose": not args.quiet,
    }


def main() -> int:
    settings = parse_args()

    # Display mode information
    if settings["dry_run"] and settings["verbose"]:
        print(f"{Colors.colorize('DRY RUN MODE', 'PURPLE')} - No changes will be made")

    if settings["verbose"]:
        print(f"{Colors.colorize('Starting dotfiles synchronization...', 'GREEN')}")
        print(f"Target repository: {TARGET_REPO}")

    gitignore_handler = GitIgnoreHandler()
    syncer = FileSyncer(gitignore_handler, settings)

    try:
        # Process all source directories and files
        for source in SOURCE_DIRS:
            if os.path.isdir(source):
                if settings["verbose"]:
                    print(
                        f"{Colors.colorize('Processing directory:', 'YELLOW')} {source}"
                    )
                syncer.process_directory(source)
            elif os.path.isfile(source):
                if settings["verbose"]:
                    print(f"{Colors.colorize('Processing file:', 'YELLOW')} {source}")
                syncer.sync_file(source, os.path.dirname(source))
            else:
                if settings["verbose"]:
                    print(f"{Colors.colorize("Source doesn't exist:", 'RED')} {source}")

        # Detect deleted files (if auto-delete enabled or if interactive and not quiet)
        if settings["auto_delete"]:
            syncer.detect_deleted_files("yes")
        elif settings["verbose"]:
            check_deleted = input("\nCheck for deleted files? (y/n): ")
            if check_deleted.lower() in ("y", "yes"):
                auto_delete = input(
                    "Automatically delete files from repo? (y/n/a for ask): "
                )

                if auto_delete.lower() in ("y", "yes"):
                    syncer.detect_deleted_files("yes")
                elif auto_delete.lower() == "a":
                    syncer.detect_deleted_files("ask")
                else:
                    syncer.detect_deleted_files("no")

        if settings["verbose"]:
            print(f"\n{Colors.colorize('Synchronization complete!', 'GREEN')}")
            print(f"Log file: {LOG_FILE}")

        return 0  # Success

    except KeyboardInterrupt:
        if settings["verbose"]:
            print(f"\n{Colors.colorize('Operation cancelled by user', 'RED')}")
        return 130  # Standard exit code for SIGINT

    except Exception as e:
        print(f"{Colors.colorize('ERROR:', 'RED')} {str(e)}")
        traceback.print_exc()
        return 1  # General error


if __name__ == "__main__":
    sys.exit(main())
