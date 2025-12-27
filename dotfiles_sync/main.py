"""
(Dot)files Synchronization Tool
Author: MihuuStrames (2025)

Simple utility to sync (dot)files between source directories and a git repository.
"""

import os
import sys
import traceback

import click

from config import COMMON_DIRS
from config import HOST_SPECIFIC_FILES
from config import HOST_TYPE
from config import LOG_FILE
from config import TARGET_REPO
from file_sync import FileSyncer
from gitignore import GitIgnoreHandler


def print_header(dry_run: bool, verbose: bool) -> None:
    """Print sync header information"""
    if not verbose:
        return

    if dry_run:
        click.secho("DRY RUN MODE - No changes will be made", fg="magenta", bold=True)

    click.echo()
    click.secho("Starting dotfiles synchronization...", fg="green")
    click.echo(f"Target: {TARGET_REPO}")
    click.echo(f"Host: {HOST_TYPE}")


def process_common_configs(syncer: FileSyncer, verbose: bool) -> None:
    """Process common configuration files shared across all systems"""
    if verbose:
        click.echo()
        click.secho("=== Processing Common Configs ===", fg="magenta")

    for source in COMMON_DIRS:
        if os.path.isdir(source):
            if verbose:
                click.secho("Processing directory: ", fg="yellow", nl=False)
                click.echo(source)
            syncer.process_directory(source)
        elif os.path.isfile(source):
            if verbose:
                click.secho("Processing file: ", fg="yellow", nl=False)
                click.echo(source)
            syncer.sync_file(source, os.path.dirname(source))
        elif verbose:
            click.secho("Source does not exist: ", fg="red", nl=False)
            click.echo(source)


def process_host_specific_configs(syncer: FileSyncer, verbose: bool) -> None:
    """Process host-specific configuration files"""
    if verbose:
        click.echo()
        click.secho(f"=== Processing Host-Specific Configs ({HOST_TYPE}) ===", fg="magenta")

    for source_file, relative_dest in HOST_SPECIFIC_FILES:
        if verbose:
            click.secho("Processing host file: ", fg="yellow", nl=False)
            click.echo(source_file)
        syncer.sync_host_specific_file(source_file, relative_dest)


def handle_deleted_files(syncer: FileSyncer, auto_delete: bool, verbose: bool) -> None:
    """Handle detection and deletion of files that no longer exist in source"""
    if auto_delete:
        syncer.detect_deleted_files("yes")
    elif verbose and click.confirm("\nCheck for deleted files?", default=False):
        mode = click.prompt(
            "Delete mode",
            type=click.Choice(["yes", "ask", "no"]),
            default="ask",
            show_choices=True,
        )
        syncer.detect_deleted_files(mode)


@click.command()
@click.option(
    "--dry-run",
    is_flag=True,
    help="Show what would be done without making changes",
)
@click.option(
    "--auto-del",
    is_flag=True,
    help="Automatically delete files from repo that no longer exist in source",
)
@click.option(
    "--quiet",
    "-q",
    is_flag=True,
    help="Reduce verbosity of output",
)
def main(dry_run: bool, auto_del: bool, quiet: bool) -> None:
    """Synchronize dotfiles between source directories and target repository"""
    verbose = not quiet

    print_header(dry_run, verbose)

    settings = {
        "dry_run": dry_run,
        "auto_delete": auto_del,
        "verbose": verbose,
    }

    gitignore_handler = GitIgnoreHandler()
    syncer = FileSyncer(gitignore_handler, settings)

    try:
        process_common_configs(syncer, verbose)
        process_host_specific_configs(syncer, verbose)
        handle_deleted_files(syncer, auto_del, verbose)

        if verbose:
            click.echo()
            click.secho("Synchronization complete!", fg="green")
            click.echo(f"Log file: {LOG_FILE}")

    except KeyboardInterrupt:
        if verbose:
            click.echo()
            click.secho("Operation cancelled by user", fg="red")
        sys.exit(130)

    except Exception as e:
        click.secho(f"ERROR: {str(e)}", fg="red", bold=True)
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
