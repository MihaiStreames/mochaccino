from pathlib import Path
import sys
import traceback

import click

from config import LOG_FILE
from config import load_config
from file_sync import FileSyncer
from ignore import IgnoreHandler


def print_header(host: str, target: Path, dry_run: bool, verbose: bool) -> None:
    """Print sync header information"""
    if not verbose:
        return

    if dry_run:
        click.secho("DRY RUN MODE - No changes will be made", fg="magenta", bold=True)

    click.echo()
    click.secho("Starting dotfiles synchronization...", fg="green")
    click.echo(f"Target: {target}")
    click.echo(f"Host: {host}")


def process_common_configs(syncer: FileSyncer, verbose: bool) -> None:
    """Process common configuration files shared across all systems"""
    if verbose:
        click.echo()
        click.secho("=== Processing Common Configs ===", fg="magenta")

    for source in syncer.cfg.common_dirs:
        if Path(source).is_dir():
            if verbose:
                click.secho("Processing directory: ", fg="yellow", nl=False)
                click.echo(source)
            syncer.process_directory(source)
        elif Path(source).is_file():
            if verbose:
                click.secho("Processing file: ", fg="yellow", nl=False)
                click.echo(source)
            syncer.sync_file(source, Path(source).parent)
        elif verbose:
            click.secho("Source does not exist: ", fg="red", nl=False)
            click.echo(source)


def process_host_specific_configs(syncer: FileSyncer, verbose: bool) -> None:
    """Process host-specific configuration files"""
    if verbose:
        click.echo()
        click.secho(f"=== Processing Host-Specific Configs ({syncer.cfg.host}) ===", fg="magenta")

    for source_file, relative_dest in syncer.cfg.host_files:
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
@click.option("--host", default=None, help="Override the host from sync.toml")
@click.option("--target", default=None, help="Override the target folder from sync.toml")
@click.option("--dry-run", is_flag=True, help="Show what would be done without making changes")
@click.option(
    "--auto-del",
    is_flag=True,
    help="Automatically delete files from target that no longer exist in source",
)
@click.option("--quiet", "-q", is_flag=True, help="Reduce verbosity of output")
def main(host: str | None, target: str | None, dry_run: bool, auto_del: bool, quiet: bool) -> None:
    """Synchronize dotfiles between source directories and target folder"""
    verbose = not quiet

    cfg = load_config(host_override=host, target_override=target)
    ignore_handler = IgnoreHandler(cfg.sync_ignore)

    print_header(cfg.host, cfg.target, dry_run, verbose)

    syncer = FileSyncer(cfg, ignore_handler, dry_run=dry_run, verbose=verbose)

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
