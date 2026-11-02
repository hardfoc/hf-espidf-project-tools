# Troubleshooting

Symptoms, causes and fixes, cheapest check first.

| Symptom | Cause | Fix |
| --- | --- | --- |
| `ERROR: Invalid app type` | The name is not a key under `apps:` | `./scripts/build_app.sh list` |
| `Invalid build combination` | The app does not allow that build type with that ESP-IDF version | `./scripts/build_app.sh info <app>` |
| `Warning: yq not found. Falling back to basic parsing.` | No `yq`; the fallback parser has limits | Install `yq` ([config_loader.sh](config-loader.md#yq-or-the-fallback-parser)) |
| Build folder is `builds/null` | `yq` is installed and `build_directory_pattern` is missing | Add both patterns under `build_config` ([app_config.yml](app-config.md#build_config)) |
| `PROJECT_PATH specified but app_config.yml not found` | `--project-path` points at the wrong folder | Point it at the folder with `app_config.yml` |
| `APP_TYPE not defined. Please use build_app.sh` | `idf.py build` was run directly | Build with `build_app.sh`, or pass the [CMake variables](project-layout.md#what-cmake-receives) |
| `Failed to setup ESP-IDF environment` | The version could not be cloned or installed | Check the version name and network; `./scripts/manage_idf.sh install` |
| `switch`/`update`/`clean` say the version is not installed | Folder name mismatch | See the [warning](manage-idf.md#commands) |
| `Invalid pairing secret format` | The secret is not 32 hex characters | `openssl rand -hex 16` |
| `No suitable serial ports found!` | No board, a charge-only cable, a missing driver | `./scripts/detect_ports.sh --verbose` |
| `Permission denied` on `/dev/ttyACM0` | The user is not in `dialout` (Linux) | `sudo usermod -aG dialout $USER`, then log in again |
| Monitor shows raw addresses | No build folder for symbol decoding (monitor only) | Build the app, or flash with `flash_app.sh` |
| `Configuration file not found` from `generate_matrix.py` | Run from a folder where none of its search paths exist | Pass `--project-path` ([generate_matrix.py](generate-matrix.md)) |
