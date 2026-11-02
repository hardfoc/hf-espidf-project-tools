# get_app_info.py

Print facts about one app from `app_config.yml`; `build_app.sh` uses it to find the source file it passes to
CMake.

```bash
python3 scripts/get_app_info.py source_file gpio_test     # GpioTest.cpp
python3 scripts/get_app_info.py list                      # gpio_test adc_test ...
python3 scripts/get_app_info.py validate gpio_test        # true (exit 0) or false (exit 1)
```

## Commands

| Command | Prints |
| --- | --- |
| `source_file <app>` | The app's `source_file`, or the first of `source_files`; exit 1 when neither is set or the app is unknown |
| `list` | Every app name on one line |
| `validate <app>` | `true` or `false`, with exit status 0 or 1 |

The script's `--help` also lists `info`, `build_types`, `idf_versions`, `dependencies`, `tags` and `category`;
those are not implemented and exit with `Unknown command`.

## Options

<!-- generated: options-get-app-info -->
| Argument | Values | Default | Description |
| --- | --- | --- | --- |
| `command` | positional, optional | - | Command to execute |
| `app_type` | positional, optional | - | Application type |
| `--help` / `-h` | flag | - | Show help message |
| `--verbose` / `-v` | flag | - | Verbose output |
| `--format` / `-f` | `text`, `json`, `yaml` | `text` | Output format |
| `--project-path` / `-p` | value | - | Path to project directory containing app_config.yml |
<!-- /generated -->

Without `--project-path` it reads `app_config.yml` in the folder above the script. `--verbose` and `--format`
are accepted and have no effect on the three commands.
