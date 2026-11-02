# config_loader.sh

The shell functions that read `app_config.yml`; `build_app.sh`, `flash_app.sh`, `manage_idf.sh` and
`idf_flash_monitor.sh` source it, and so can your own scripts.

```bash
source ./scripts/config_loader.sh        # finds the project, loads the defaults
get_app_types                            # gpio_test adc_test ...
get_build_directory gpio_test Debug      # <project>/builds/build-app-gpio_test-type-Debug-...
```

Run directly (`./scripts/config_loader.sh`), it prints the list of functions.

## What sourcing it does

1. Sets `PROJECT_DIR` and `CONFIG_FILE` from `PROJECT_PATH`, or from `scripts/..`
   ([Project layout](project-layout.md#how-the-project-is-found)).
2. Exports `CONFIG_DEFAULT_APP`, `CONFIG_DEFAULT_BUILD_TYPE`, `CONFIG_TARGET` and `CONFIG_DEFAULT_IDF_VERSION`
   from `metadata`.

## Functions

| Function | Returns |
| --- | --- |
| `get_app_types` | Every app name, space-separated |
| `get_featured_app_types`, `get_ci_app_types` | Apps with `featured: true` / `ci_enabled: true` |
| `get_app_description <app>`, `get_app_source_file <app>` | The app's `description` / `source_file` |
| `is_valid_app_type <app>` | Exit status 0 when the app exists |
| `get_build_types [app]` | The app's build types, or every build type in `metadata` |
| `is_valid_build_type <type> [app] [idf_version]` | Exit status 0 when allowed |
| `get_idf_versions` | `metadata.idf_versions` |
| `get_idf_version [app]`, `get_target [app]` | The app's first ESP-IDF version / target, or the global one |
| `get_idf_version_for_build_type <app> <type>` | The first of the app's versions that allows the build type |
| `get_idf_version_index <version>` | The version's position in `metadata.idf_versions` |
| `get_build_types_for_idf_version <version>`, `get_app_build_types_for_idf_version <app> <version>` | Build types allowed for that version |
| `is_valid_combination <app> <type> <version>` | Exit status 0 when the combination is allowed |
| `show_valid_combinations <app>` | Prints the allowed combinations |
| `get_build_directory <app> <type> [target] [version]` | Absolute build folder path |
| `get_project_name <app>` | The ESP-IDF project name |
| `parse_build_directory <name>`, `get_build_component <name> <part>`, `is_valid_build_directory <name>`, `list_build_directories` | Read build folder names back into their parts |

## yq or the fallback parser

With [`yq`](https://github.com/mikefarah/yq) on the `PATH` (version 4 uses `yq eval`, older versions the direct
syntax) the functions query the YAML. Without it they print `Warning: yq not found. Falling back to basic parsing.`
once and use `grep` and `sed`, which:

- need `idf_versions` and `build_types` written as one-line arrays;
- find app names only between `apps:` and `build_config:`;
- ignore `build_directory_pattern` and `project_name_pattern` and use fixed names
  ([app_config.yml](app-config.md#build_config));
- return a fixed list of featured apps and treat every app as CI-enabled.

Install `yq` for anything beyond the simple layout; `setup_repo.sh` does.
