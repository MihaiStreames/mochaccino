import os
from pathlib import Path

import pathspec

from config import COMMON_DIRS
from config import TARGET_REPO


class GitIgnoreHandler:
    """Loads and matches gitignore patterns from source directories"""

    _spec: "pathspec.PathSpec | None"

    def _load_gitignore_patterns(self) -> None:
        """Load and combine all .gitignore patterns"""
        patterns: list[str] = []

        def read_patterns(filepath: str) -> None:
            """Read non-comment, non-empty lines from gitignore file"""
            if not Path(filepath).is_file():
                return
            with Path(filepath).open() as f:
                patterns.extend(
                    line.strip() for line in f if line.strip() and not line.startswith("#")
                )

        read_patterns(str(Path(TARGET_REPO) / ".gitignore"))

        for source in COMMON_DIRS:
            gitignore_path = (
                str(Path(source) / ".gitignore")
                if Path(source).is_dir()
                else str(Path(source).parent / ".gitignore")
            )
            read_patterns(gitignore_path)

        if patterns:
            self._spec = pathspec.PathSpec.from_lines("gitwildmatch", patterns)

    def __init__(self):
        self._spec = None
        self._load_gitignore_patterns()

    def should_ignore(self, path: str | Path, base_path: str | Path) -> bool:
        """Check if a file should be ignored based on gitignore patterns"""
        if not self._spec:
            return False

        relative_path = os.path.relpath(str(path), str(base_path))
        return self._spec.match_file(relative_path)
