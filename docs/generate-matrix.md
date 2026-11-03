# generate_matrix.py

Turn `app_config.yml` into the build matrix of a GitHub Actions job: one entry per app, ESP-IDF version and build
type.

```bash
python3 scripts/generate_matrix.py                         # JSON on stdout
python3 scripts/generate_matrix.py --validate --verbose    # check the file first
python3 scripts/generate_matrix.py --filter gpio_test --format yaml
```

## Options

<!-- generated: options-generate-matrix -->
| Argument | Values | Default | Description |
| --- | --- | --- | --- |
| `--help` / `-h` | flag | - | Show help message |
| `--output` / `-o` | value | - | Output file path |
| `--format` / `-f` | `json`, `yaml` | `json` | Output format |
| `--filter` | value | - | Filter output for specific app |
| `--verbose` / `-v` | flag | - | Verbose output |
| `--validate` | flag | - | Validate configuration |
| `--project-path` / `-p` | value | - | Path to project directory containing app_config.yml |
<!-- /generated -->

Without `--project-path` the script looks for `examples/esp32/app_config.yml`, `app_config.yml`,
`../app_config.yml`, `../../examples/esp32/app_config.yml` (all from the current directory) and finally
`app_config.yml` in the folder above the script, and uses the first that exists.

## Output

```json
{"include": [
  {"idf_version": "release/v5.5", "idf_version_docker": "release-v5.5", "idf_version_file": "release_v5_5",
   "build_type": "Debug", "app_name": "gpio_test", "target": "esp32c6", "config_source": "global"}
]}
```

| Field | Meaning |
| --- | --- |
| `idf_version` | As written in `app_config.yml`; passed to `build_app.sh` |
| `idf_version_docker` | `/` replaced by `-`: the `espressif/idf` image tag and the artifact name |
| `idf_version_file` | `/` and `.` replaced by `_`: the build folder suffix |
| `build_type`, `app_name`, `target` | The combination |
| `config_source` | `app` when the app overrides `idf_versions` or `build_types`, else `global` |

## Rules

1. Apps with `ci_enabled: false` are skipped.
2. Each app uses its own `idf_versions`, or `metadata.idf_versions`.
3. Build types: the app's flat `build_types` list for every version; or its nested list by position; or
   `metadata.build_types` by position; `Debug` and `Release` when a position has no list.
4. `metadata.target`, default `esp32c6`.
5. Entries matching an item of `ci_config.exclude_combinations` on every key are dropped.

`--validate` fails on a missing `metadata` or `apps` section, an empty `apps`, or `build_types` / `idf_versions`
that are not lists of strings, and warns on missing defaults, descriptions or source files. `--validate` and
`--verbose` print their messages on standard output before the matrix, so leave them out where the output is
parsed as JSON (use `--output` to write the matrix to a file instead).
