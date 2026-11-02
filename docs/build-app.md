# build_app.sh

Build one app of the project for one build type and ESP-IDF version, in its own build folder.

```bash
./scripts/build_app.sh [options] <app> <build_type> [idf_version]
./scripts/build_app.sh list | combinations | info <app> | validate <app> <build_type> [idf_version]
```

## Arguments

| Argument | Meaning |
| --- | --- |
| `app` | An app name from `app_config.yml`; default `metadata.default_app` |
| `build_type` | `Debug`, `Release` or another type the app allows; default `metadata.default_build_type` |
| `idf_version` | ESP-IDF branch or tag, for example `release/v5.5`; default: the first of the app's versions that allows the build type |

| Option | Environment | Effect |
| --- | --- | --- |
| `--clean` / `--no-clean` | `CLEAN=1` / `CLEAN=0` | Delete the build folder first, or keep it (incremental, the default) |
| `--use-cache` / `--no-cache` | `USE_CCACHE=1` / `USE_CCACHE=0` | ccache on or off (passed as `IDF_CCACHE_ENABLE`) |
| `--project-path <path>` | `PROJECT_PATH` | The project directory ([Project layout](project-layout.md#how-the-project-is-found)) |
| `--secret <hex>` | `ESPNOW_PAIRING_SECRET` | ESP-NOW pairing secret ([Project layout](project-layout.md#esp-now-pairing-secret)) |
| `-h`, `--help` | | Usage |

Options can go anywhere on the line.

## Commands

| Command | Prints |
| --- | --- |
| `list` | Featured apps, all apps with descriptions, build types, ESP-IDF versions |
| `combinations` | Every allowed app, build type and ESP-IDF version |
| `info <app>` | The allowed combinations of one app |
| `validate <app> <build_type> [idf_version]` | Whether the combination is allowed |

## What a build does

<div class="hf-steps" markdown>

1. Checks the app, the build type and the full combination against `app_config.yml`; a combination the file
   does not allow stops here, with the allowed ones listed.
2. If `idf.py` is not on the `PATH`, installs (when missing) and exports the ESP-IDF version from `~/esp`
   ([manage_idf.sh](manage-idf.md)).
3. Sets `IDF_TARGET` from `metadata.target`.
4. Reads the app's source file with `get_app_info.py source_file <app>`.
5. Runs `idf.py -B <build folder> reconfigure` with the [CMake variables](project-layout.md#what-cmake-receives),
   then `idf.py build`.
6. Writes `size.txt` (`idf.py size`), `size.json` when supported, `size.info` and `size.meta` into the build
   folder.

</div>

## Output

| File in the build folder | Content |
| --- | --- |
| `<project_name>.bin`, `.elf`, `.map` | Firmware, from `build_config.project_name_pattern` |
| `size.txt` | `idf.py size` output |
| `size.json` | `idf.py size-json` output, when the ESP-IDF version has it |
| `size.info` | `APP=`, `BUILD=`, `IDF=`, `TARGET=`, `PROJECT_NAME=`, `BUILD_DIR=` lines; read by the CI size report |
| `size.meta` | `ELF_FILE=` and `MAP_FILE=` paths |

## Examples

```bash
./scripts/build_app.sh gpio_test Release                     # default ESP-IDF version for Release
./scripts/build_app.sh gpio_test Debug release/v5.4 --clean  # a specific version, from scratch
./scripts/build_app.sh --project-path ../fw gpio_test Debug  # scripts outside the project
CLEAN=1 USE_CCACHE=0 ./scripts/build_app.sh gpio_test Debug  # the same through the environment
```

Next: [flash_app.sh](flash-app.md).
