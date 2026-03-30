import fnmatch
from pathlib import Path


class IgnoreHandler:
    """Matches files against a list of ignore patterns"""

    def __init__(self, patterns: list[str]) -> None:
        self.patterns = patterns

    def should_ignore(self, path: str | Path, _base_path: str | Path) -> bool:
        """Check if a file should be ignored based on patterns"""
        parts = Path(path).parts
        name = Path(path).name

        for pattern in self.patterns:
            # directory/component match (e.g. ".git", "__pycache__")
            if not any(c in pattern for c in ("*", "?", "[")):
                if pattern in parts:
                    return True
            # glob match against filename (e.g. "*.pyc")
            elif fnmatch.fnmatch(name, pattern):
                return True

        return False
