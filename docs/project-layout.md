# Project layout

Where the scripts expect the project, where they put builds and logs, and what CMake receives from them.

## Folders

```text
examples/esp32/                  the ESP-IDF project ("project directory")
├── CMakeLists.txt
├── app_config.yml               read by every script
├── main/                        the app sources named in app_config.yml
├── scripts/                     this repository (submodule)
├── builds/                      created by build_app.sh, one folder per build
├── logs/                        created by flash_app.sh --log
└── secrets.local.yml            optional, ESP-NOW pairing secret (keep it out of git)
```

## How the project is found

| Way | Project directory |
| --- | --- |
| Nothing set | The folder above the script (`scripts/..`) |
| `--project-path <path>` (`build_app.sh`, `flash_app.sh`, `manage_idf.sh`) | That path, relative to the current directory or absolute |
| `PROJECT_PATH=<path>` in the environment | Same as the flag; the flag sets this variable |
| `--project-path` / `-p` (`generate_matrix.py`, `get_app_info.py`) | That path |

With a path set, `config_loader.sh` stops with an error when `<path>/app_config.yml` does not exist.
`manage_logs.sh`, `idf_flash_monitor.sh` and `setup_common.sh` always use `scripts/..`.

## Build folders

Every build has its own folder, so switching app, build type or ESP-IDF version never reuses another build's
cache:

```text
<project>/builds/<build_config.build_directory_pattern>
```

The placeholders `{app_type}`, `{build_type}`, `{target}` and `{idf_version}` are replaced; the ESP-IDF version
has `/` and `.` turned into `_` (`release/v5.5` becomes `release_v5_5`). Without `yq` the pattern is not read and
`build-app-{app_type}-type-{build_type}-target-{target}-idf-{idf_version}` is used.

## What CMake receives

`build_app.sh` runs `idf.py -B <build folder> reconfigure` and then `build` with:

| Variable | Value |
| --- | --- |
| `APP_TYPE` | The app name from `app_config.yml` |
| `BUILD_TYPE`, `CMAKE_BUILD_TYPE` | The build type, for example `Debug` |
| `APP_SOURCE_FILE` | The app's `source_file` (or the first of `source_files`), from `get_app_info.py` |
| `IDF_CCACHE_ENABLE` | `1` unless `--no-cache` or `USE_CCACHE=0` |
| `ESPNOW_PAIRING_SECRET_HEX` | Only when a pairing secret is configured ([below](#esp-now-pairing-secret)) |

ESP-IDF configures components once without these variables (the requirements phase), so a component that reads
them needs a default. `setup_basic.sh` writes a project that does this:

```cmake title="main/CMakeLists.txt (from setup_basic.sh)"
if(NOT DEFINED APP_SOURCE_FILE)
    if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
        set(APP_SOURCE_FILE "${DEFAULT_SOURCE_FILE}")   # requirements phase
    else()
        message(FATAL_ERROR "APP_SOURCE_FILE not defined. Please use build_app.sh to build this project.")
    endif()
endif()

idf_component_register(SRCS "${APP_SOURCE_FILE}" REQUIRES driver esp_timer freertos log)
target_compile_definitions(${COMPONENT_LIB} PRIVATE "APP_TYPE_${APP_TYPE}=1")
```

## ESP-NOW pairing secret

Projects that pair boards over ESP-NOW take a 32-hex-character secret. `build_app.sh` looks, in order, at
`--secret <hex>`, the `ESPNOW_PAIRING_SECRET` environment variable and `espnow_pairing_secret:` in
`<project>/secrets.local.yml`, and passes the first one it finds as `ESPNOW_PAIRING_SECRET_HEX`. A value that is
not 32 hex characters stops the build. With none, a Release build prints a warning and continues. Generate one
with `openssl rand -hex 16`.

Next: [app_config.yml](app-config.md).
