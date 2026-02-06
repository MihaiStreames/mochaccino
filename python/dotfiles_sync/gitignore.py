import os
from pathlib import Path

import pathspec

from config import COMMON_DIRS
from config import TARGET_REPO


class GitIgnoreHandler:
    """Loads and matches gitignore patterns from source directories"""

    def _load_gitignore_patterns(self) -> None:
        """Load and combine all .gitignore patterns"""
        patterns = []

        def read_patterns(filepath: str) -> None:
            """Read non-comment, non-empty lines from gitignore file"""
            if not os.path.isfile(filepath):
                return
            with open(filepath) as f:
                patterns.extend(
                    line.strip() for line in f if line.strip() and not line.startswith("#")
                )

        # Load repo .gitignore
        read_patterns(os.path.join(TARGET_REPO, ".gitignore"))

        # Load .gitignore from source directories
        for source in COMMON_DIRS:
            gitignore_path = (
                os.path.join(source, ".gitignore")
                if os.path.isdir(source)
                else os.path.join(os.path.dirname(source), ".gitignore")
            )
            read_patterns(gitignore_path)

        if patterns:
            self.spec = pathspec.PathSpec.from_lines("gitwildmatch", patterns)

    def __init__(self):
        self.spec: pathspec.PathSpec | None = None
        self._load_gitignore_patterns()

    def should_ignore(self, path: str | Path, base_path: str | Path) -> bool:
        """Check if a file should be ignored based on gitignore patterns"""
        if not self.spec:
            return False

        relative_path = os.path.relpath(str(path), str(base_path))
        return self.spec.match_file(relative_path)
