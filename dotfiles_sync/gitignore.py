import os
import pathspec
from functools import lru_cache
from pathlib import Path
from typing import Dict, Optional, List, Union

from config import SOURCE_DIRS, TARGET_REPO


class GitIgnoreHandler:
    """
    Handles .gitignore patterns for determining which files to ignore.
    """

    def __init__(self):
        self.spec: Optional[pathspec.PathSpec] = None
        # Cache of ignore decisions for paths to improve performance
        self.cache: Dict[str, bool] = {}
        self._load_gitignore_patterns()

    def _load_gitignore_patterns(self) -> None:
        """Load and combine all .gitignore patterns."""
        patterns: List[str] = []

        # Helper function to read patterns from a file
        def read_patterns(filepath: str) -> None:
            if not os.path.isfile(filepath):
                return

            with open(filepath, 'r') as f:
                patterns.extend([line.strip() for line in f
                                 if line.strip() and not line.startswith('#')])

        # Add repository .gitignore
        read_patterns(os.path.join(TARGET_REPO, ".gitignore"))

        # Add source .gitignore files
        for source in SOURCE_DIRS:
            if os.path.isdir(source):
                read_patterns(os.path.join(source, ".gitignore"))
            elif os.path.isfile(source):
                read_patterns(os.path.join(os.path.dirname(source), ".gitignore"))

        # Create pathspec object to match patterns if we have any
        if patterns:
            self.spec = pathspec.PathSpec.from_lines('gitwildmatch', patterns)

    @lru_cache(maxsize=1024)
    def should_ignore(self, path: Union[str, Path], base_path: Union[str, Path]) -> bool:
        """
        Check if a file should be ignored based on gitignore patterns.
        """
        if not self.spec: return False

        # Convert paths to strings
        path_str = str(path)
        base_path_str = str(base_path)

        # Calculate the relative path for matching
        relative_path = os.path.relpath(path_str, base_path_str)

        # Check if path matches any ignore pattern
        return self.spec.match_file(relative_path)
