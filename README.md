# ESP-IDF Project Tools

Shell and Python scripts that build, flash and monitor every app of a multi-app ESP-IDF project from one
`app_config.yml`, on your machine and in CI.

[![YAML lint](https://github.com/hardfoc/hf-espidf-project-tools/actions/workflows/yamllint.yml/badge.svg?branch=main)](https://github.com/hardfoc/hf-espidf-project-tools/actions/workflows/yamllint.yml)
[![Docs](https://github.com/hardfoc/hf-espidf-project-tools/actions/workflows/ci-docs-publish.yml/badge.svg?branch=main)](https://hardfoc.github.io/hf-espidf-project-tools/)
[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)

**Documentation: <https://hardfoc.github.io/hf-espidf-project-tools/>**

<!-- figure: tool-map -->
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/diagrams/tool-map.dark.svg">
  <img src="docs/diagrams/tool-map.svg"
    alt="Diagram: app_config.yml is read by config_loader.sh and by the Python scripts generate_matrix.py and
    get_app_info.py; build_app.sh, flash_app.sh, manage_idf.sh and idf_flash_monitor.sh use them;
    build_app.sh runs idf.py into a build folder under builds/; hf-espidf-ci-tools calls
    generate_matrix.py and build_app.sh.">
</picture>
<!-- /figure -->

## In 30 seconds

With the apps listed in `examples/esp32/app_config.yml` and these scripts in `examples/esp32/scripts`:

```bash
./scripts/build_app.sh list                     # apps, build types, ESP-IDF versions
./scripts/build_app.sh gpio_test Debug          # build into builds/build-app-gpio_test-type-Debug-...
./scripts/flash_app.sh gpio_test Debug          # flash and monitor; finds the port, builds if needed
```

## What it does

- Builds each app, build type and ESP-IDF version into its own folder under `builds/`, so switching never
  reuses another build's cache.
- Refuses combinations `app_config.yml` does not allow, and lists the ones it does.
- Installs and exports the ESP-IDF versions the project asks for, under `~/esp`.
- Finds the board's serial port on Linux and macOS, flashes, monitors and logs the monitor output.
- Turns `app_config.yml` into the GitHub Actions matrix that
  [hf-espidf-ci-tools](https://github.com/hardfoc/hf-espidf-ci-tools) builds, with size files for its report.

## Install

```bash
cd examples/esp32
git submodule add https://github.com/hardfoc/hf-espidf-project-tools.git scripts
pip install -r scripts/requirements.txt
```

The project's `main` component compiles the file `build_app.sh` passes as `APP_SOURCE_FILE`; see
[Project layout](https://hardfoc.github.io/hf-espidf-project-tools/latest/project-layout/).

## Documentation

| Page | What it covers |
| --- | --- |
| [Quickstart](https://hardfoc.github.io/hf-espidf-project-tools/latest/quickstart/) | Add the scripts, describe an app, build and flash |
| [app_config.yml](https://hardfoc.github.io/hf-espidf-project-tools/latest/app-config/) | Every key, its default and which script reads it |
| [build_app.sh](https://hardfoc.github.io/hf-espidf-project-tools/latest/build-app/) | Arguments, build folders, size files, CMake variables |
| [flash_app.sh](https://hardfoc.github.io/hf-espidf-project-tools/latest/flash-app/) | Operations, port search, logging |
| [manage_idf.sh](https://hardfoc.github.io/hf-espidf-project-tools/latest/manage-idf/) | ESP-IDF versions under `~/esp` |
| [Using in CI](https://hardfoc.github.io/hf-espidf-project-tools/latest/ci/) | The matrix and the build in GitHub Actions |

## Tests

```bash
cd examples/esp32/scripts/tests && ./test_tab_completion.sh
```

## License

GPL-3.0; see [LICENSE](LICENSE).
