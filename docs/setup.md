# Setting up a machine

Install the toolchain on a development machine, or start a new project with the scripts already in place.

## setup_repo.sh: a development machine

Run once per machine, from a project that contains the scripts, as a normal user with `sudo`:

```bash
./scripts/setup_repo.sh
```

After a confirmation prompt it installs, in order:

1. System packages for Ubuntu, Fedora, CentOS or macOS (build tools, libraries).
2. The Clang 20 tools (compiler, `clang-format`, `clang-tidy`).
3. `yq`.
4. Every ESP-IDF version in the project's `metadata.idf_versions` (`release/v5.5` when there is no
   `app_config.yml`) into `~/esp/esp-idf-<version>`.
5. The Python packages.
6. Aliases in `~/.bashrc`: `get_idf`, `build_app`, `flash_app`, `list_apps`.

It then checks the installation. Plan for about 2 GB per ESP-IDF version.

## setup_basic.sh: a new project

```bash
./setup_basic.sh [project_name] [espidf_version]     # defaults: my-esp-idf-project, release/v5.5
```

Creates `project_name/`, runs `git init`, adds this repository as the `scripts` submodule, installs the ESP-IDF
version (`v5.5` is read as `release/v5.5`), and writes `main/main.cpp`, the two `CMakeLists.txt` files that
follow the [CMake contract](project-layout.md#what-cmake-receives), an `app_config.yml` with one app
(`main_app`), a `.gitignore` and a `README.md`. Then:

```bash
cd my-esp-idf-project
./scripts/build_app.sh main_app Release
```

## setup_common.sh

The functions both scripts use (OS detection, package installation, ESP-IDF install and export, environment
setup). `build_app.sh` sources it to install a missing ESP-IDF version. It is not run directly.

## Python packages

`requirements.txt` lists what the Python scripts and the CI need: `pyyaml`, `esptool`, `pyserial`,
`esp-idf-kconfig`, `esp-idf-size`.

```bash
pip install -r scripts/requirements.txt
```
