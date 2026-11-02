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
| `info <app>` | Every key of the app, plus `idf_versions` and `build_types` resolved as below |
| `idf_versions <app>` | The app's `idf_versions`, else `metadata.idf_versions` |
| `build_types <app>` | One line per ESP-IDF version: the app's `build_types` (a flat list applies to every version), else the `metadata.build_types` entry at that version's position |
| `dependencies <app>`, `tags <app>`, `category <app>` | That key of the app; nothing when it is not set |

An unknown app exits with status 1 for every command except `validate`, which prints `false`.

## Options

<!-- generated: options-get-app-info -->
| Argument | Values | Default | Description |
| --- | --- | --- | --- |
| `command` | positional, optional | - | Command to execute |
| `app_type` | positional, optional | - | Application type |
| `--help` / `-h` | flag | - | Show help message |
| `--verbose` / `-v` | flag | - | Accepted for compatibility; no effect |
| `--format` / `-f` | `text`, `json`, `yaml` | `text` | Output format |
| `--project-path` / `-p` | value | - | Path to project directory containing app_config.yml |
<!-- /generated -->

Without `--project-path` it reads `app_config.yml` in the folder above the script. `--format json` or
`--format yaml` prints the same data as JSON or YAML (`build_types` as a map from version to list, a missing key as
`null`); `text` is the default. `--verbose` is accepted and has no effect.
