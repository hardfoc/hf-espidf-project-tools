#!/usr/bin/env python3
"""
ESP32 App Information Script
This script provides information about ESP32 apps from configuration
"""

import sys
import json
import yaml
import argparse
from pathlib import Path

def show_help():
    """Show help information."""
    print("ESP32 App Information Script")
    print("")
    print("Usage: python3 get_app_info.py [COMMAND] [APP_TYPE] [OPTIONS]")
    print("")
    print("COMMANDS:")
    print("  source_file <app_type>      - Source file passed to CMake (first of source_files)")
    print("  list                        - List all available apps")
    print("  validate <app_type>         - Print true/false and exit 0/1 if the app exists")
    print("  info <app_type>             - Show every key of the app, with versions and build types resolved")
    print("  build_types <app_type>      - Build types per ESP-IDF version (app value, else metadata)")
    print("  idf_versions <app_type>     - ESP-IDF versions (app value, else metadata)")
    print("  dependencies <app_type>     - The app's dependencies key")
    print("  tags <app_type>             - The app's tags key")
    print("  category <app_type>         - The app's category key")
    print("")
    print("OPTIONS:")
    print("  --help, -h                  - Show this help message")
    print("  --format <format>           - Output format: text, json, yaml (default: text)")
    print("  --project-path <path>       - Path to project directory containing app_config.yml")
    print("")
    print("EXAMPLES:")
    print("  python3 get_app_info.py list")
    print("  python3 get_app_info.py source_file gpio_test")
    print("  python3 get_app_info.py validate adc_test")
    print("  python3 get_app_info.py info gpio_test --format json")
    print("  python3 get_app_info.py build_types gpio_test")
    print("  python3 get_app_info.py list --project-path /path/to/project")
    print("")
    print("CONFIGURATION FILE:")
    print("  app_config.yml in --project-path, else in the folder above this script")
    print("")
    print("A key the app does not set prints nothing in text format (null in json/yaml).")
    sys.exit(0)


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Get information about ESP32 apps from configuration",
        add_help=False  # We'll handle help manually
    )
    
    parser.add_argument("command", nargs="?", help="Command to execute")
    parser.add_argument("app_type", nargs="?", help="Application type")
    parser.add_argument("--help", "-h", action="store_true", help="Show help message")
    parser.add_argument("--verbose", "-v", action="store_true", help="Accepted for compatibility; no effect")
    parser.add_argument("--format", "-f", choices=["text", "json", "yaml"], default="text", help="Output format")
    parser.add_argument("--project-path", "-p", help="Path to project directory containing app_config.yml")
    
    args = parser.parse_args()
    
    if args.help or not args.command:
        show_help()
    
    return args

def load_config(project_path=None):
    """Load the apps configuration file."""
    if project_path:
        # Use provided project path
        project_dir = Path(project_path).resolve()
        config_file = project_dir / "app_config.yml"
    else:
        # Default behavior: assume script is in project/scripts/
        config_file = Path(__file__).parent.parent / "app_config.yml"
    
    if not config_file.exists():
        print(f"Error: Configuration file not found: {config_file}", file=sys.stderr)
        if project_path:
            print(f"Please check the project path: {project_path}", file=sys.stderr)
        sys.exit(1)
    
    try:
        with open(config_file, 'r') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Error loading configuration: {e}", file=sys.stderr)
        sys.exit(1)

def get_app_source_file(app_type, project_path=None):
    """Get source file for an app type."""
    config = load_config(project_path)
    
    if app_type not in config['apps']:
        print(f"Error: Unknown app type: {app_type}", file=sys.stderr)
        sys.exit(1)
    
    app_config = config['apps'][app_type]
    
    # Support both 'source_file' (single) and 'source_files' (list)
    if 'source_files' in app_config:
        # Return first file for CMake APP_SOURCE_FILE (CMake will glob the rest)
        return app_config['source_files'][0]
    elif 'source_file' in app_config:
        return app_config['source_file']
    else:
        print(f"Error: No source_file or source_files defined for {app_type}", file=sys.stderr)
        sys.exit(1)

def list_apps(project_path=None):
    """List all available apps."""
    config = load_config(project_path)
    apps = list(config['apps'].keys())
    return apps

def validate_app(app_type, project_path=None):
    """Validate if app type exists."""
    config = load_config(project_path)
    return app_type in config['apps']

DEFAULT_IDF_VERSIONS = ["release/v5.5"]
DEFAULT_BUILD_TYPES = [["Debug", "Release"]]


def get_app(app_type, project_path=None):
    """Return (config, app_config) for an app type, exiting when it is unknown."""
    config = load_config(project_path)
    if app_type not in config['apps']:
        print(f"Error: Unknown app type: {app_type}", file=sys.stderr)
        sys.exit(1)
    return config, config['apps'][app_type] or {}


def resolve_idf_versions(config, app_config):
    """The app's idf_versions, else metadata.idf_versions, else the default."""
    metadata = config.get('metadata') or {}
    return app_config.get('idf_versions') or metadata.get('idf_versions') or DEFAULT_IDF_VERSIONS


def resolve_build_types(config, app_config):
    """Build types as {idf_version: [types]}: the app's own value (flat or one list per version), else the
    metadata list at the same position as the version in metadata.idf_versions."""
    metadata = config.get('metadata') or {}
    versions = resolve_idf_versions(config, app_config)
    app_types = app_config.get('build_types')
    if app_types:
        if all(isinstance(t, list) for t in app_types):
            return {v: app_types[min(i, len(app_types) - 1)] for i, v in enumerate(versions)}
        return {v: list(app_types) for v in versions}
    meta_versions = metadata.get('idf_versions') or DEFAULT_IDF_VERSIONS
    meta_types = metadata.get('build_types') or DEFAULT_BUILD_TYPES
    result = {}
    for v in versions:
        i = meta_versions.index(v) if v in meta_versions else 0
        result[v] = meta_types[min(i, len(meta_types) - 1)]
    return result


def emit(value, fmt):
    """Print a value as text, json or yaml."""
    if fmt == "json":
        print(json.dumps(value, indent=2))
    elif fmt == "yaml":
        text = yaml.safe_dump(value, default_flow_style=False, sort_keys=False)
        print(text.replace("\n...\n", "\n").rstrip())
    elif value is None:
        return
    elif isinstance(value, bool):
        print("true" if value else "false")
    elif isinstance(value, dict):
        for key, item in value.items():
            print(f"{key}: {_text(item)}")
    else:
        print(_text(value))


def _text(value):
    if isinstance(value, dict):
        return "; ".join(f"{k}: {_text(v)}" for k, v in value.items())
    if isinstance(value, list):
        return " ".join(_text(v) for v in value)
    if isinstance(value, bool):
        return "true" if value else "false"
    return "" if value is None else str(value)


APP_COMMANDS = ("source_file", "validate", "info", "build_types", "idf_versions", "dependencies", "tags",
                "category")


def main():
    """Main function."""
    args = parse_arguments()

    command = args.command
    app_type = args.app_type
    fmt = args.format
    project_path = args.project_path

    if command in APP_COMMANDS and not app_type:
        print(f"Usage: get_app_info.py {command} <app_type>", file=sys.stderr)
        sys.exit(1)

    if command == "source_file":
        emit(get_app_source_file(app_type, project_path), fmt)

    elif command == "list":
        apps = list_apps(project_path)
        if fmt == "text":
            print(" ".join(apps))
        else:
            emit(apps, fmt)

    elif command == "validate":
        is_valid = validate_app(app_type, project_path)
        emit(is_valid, fmt)
        if not is_valid:
            sys.exit(1)

    elif command == "info":
        config, app_config = get_app(app_type, project_path)
        info = {"name": app_type}
        info.update(app_config)
        info["idf_versions"] = resolve_idf_versions(config, app_config)
        info["build_types"] = resolve_build_types(config, app_config)
        emit(info, fmt)

    elif command == "build_types":
        config, app_config = get_app(app_type, project_path)
        emit(resolve_build_types(config, app_config), fmt)

    elif command == "idf_versions":
        config, app_config = get_app(app_type, project_path)
        emit(resolve_idf_versions(config, app_config), fmt)

    elif command in ("dependencies", "tags", "category"):
        _, app_config = get_app(app_type, project_path)
        emit(app_config.get(command), fmt)

    else:
        print(f"Error: Unknown command: {command}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
