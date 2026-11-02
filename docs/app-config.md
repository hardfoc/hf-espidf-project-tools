# app_config.yml

Every key of the project's `app_config.yml`, its default and which script reads it.

The file sits in the project directory ([Project layout](project-layout.md)). The shell scripts read it through
[config_loader.sh](config-loader.md); `generate_matrix.py` and `get_app_info.py` read it with PyYAML.

## Example

```yaml
---
version: "1.0"
metadata:
  project: "ESP32 TMC9660 Driver Examples"
  default_app: "bldc_comprehensive_test"
  default_build_type: "Release"
  target: "esp32c6"
  idf_versions: ["release/v5.5", "release/v5.4"]
  build_types: [["Debug", "Release"], ["Debug"]]

apps:
  bldc_comprehensive_test:
    description: "BLDC motor test with Hall sensors and velocity control"
    source_file: "bldc_comprehensive_test.cpp"
    idf_versions: ["release/v5.5"]
    build_types: ["Debug", "Release"]
    ci_enabled: true
    featured: true

build_config:
  build_directory_pattern: "build-app-{app_type}-type-{build_type}-target-{target}-idf-{idf_version}"
  project_name_pattern: "esp32_{app_type}_app"

ci_config:
  exclude_combinations:
    - {app_name: bldc_comprehensive_test, build_type: Release}
```

## metadata

| Key | Default | Read by | Meaning |
| --- | --- | --- | --- |
| `default_app` | none | `build_app.sh`, `flash_app.sh` | App used when no app is given |
| `default_build_type` | none | `build_app.sh`, `flash_app.sh` | Build type used when none is given |
| `target` | `esp32c6` (`generate_matrix.py`) | all | Chip passed to ESP-IDF (`IDF_TARGET`) |
| `idf_versions` | `["release/v5.5"]` | all | ESP-IDF branches or tags; the first is the default and is installed first |
| `build_types` | `[["Debug", "Release"]]` | all | One list per entry of `idf_versions`, by position |
| `project` | none | none (descriptive) | Project title |

## apps.&lt;name&gt;

The key is the app name used on the command line (`gpio_test`) and passed to CMake as `APP_TYPE`.

| Key | Default | Meaning |
| --- | --- | --- |
| `source_file` | required (or `source_files`) | File passed to CMake as `APP_SOURCE_FILE` |
| `source_files` | none | A list; the first entry is passed as `APP_SOURCE_FILE` |
| `description` | none | Shown by `build_app.sh list`; `generate_matrix.py --validate` warns when missing |
| `idf_versions` | `metadata.idf_versions` | ESP-IDF versions for this app |
| `build_types` | from `metadata` | A flat list for every version, or one list per version |
| `ci_enabled` | `true` | `false` leaves the app out of the CI matrix |
| `featured` | `false` | Listed first by `build_app.sh list` and `flash_app.sh list` (with `yq`) |
| `target` | `metadata.target` | Read only by `idf_flash_monitor.sh`; `build_app.sh` and the matrix use `metadata.target` |
| `category`, `tags`, `dependencies` | none | Descriptive; no script reads them |

## build_config

| Key | Meaning |
| --- | --- |
| `build_directory_pattern` | Build folder name under `builds/`, with `{app_type}`, `{build_type}`, `{target}`, `{idf_version}` |
| `project_name_pattern` | ESP-IDF project name, with `{app_type}`; used to find the `.bin` to flash |
| `build_types.<name>` | Descriptive (flags, defines); CMake sets the real flags |

!!! warning "Set both patterns when yq is installed"
    With `yq` the scripts read the two patterns as they are; a missing key gives the literal `null` (a build
    folder named `builds/null`). Without `yq` they are ignored and fixed defaults are used:
    `build-app-{app_type}-type-{build_type}-target-{target}-idf-{idf_version}` and `esp32_iid_{app_type}_app`.

## ci_config

| Key | Meaning |
| --- | --- |
| `exclude_combinations` | Matrix entries to drop: an entry is dropped when every key of an item matches (`app_name`, `build_type`, `idf_version`, `target`) |

Other keys under `ci_config` (`timeout_minutes`, `fail_fast`, `special_apps`) are not read; the CI workflow sets
its own timeout and `fail-fast: false`.

## How the matrix and the local scripts agree

`build_app.sh` refuses a combination the configuration does not allow (`is_valid_combination` in
[config_loader.sh](config-loader.md)), and `generate_matrix.py` emits exactly the allowed combinations. When an
ESP-IDF version is not given, `build_app.sh` picks the first version of the app whose build types include the
requested one.

!!! note "Keep arrays on one line without yq"
    The fallback parser reads `idf_versions` and `build_types` from a single line, and reads app names between
    `apps:` and `build_config:`. Write arrays in the inline form shown above and keep `build_config` after `apps`.
