---
hide:
  - navigation
  - toc
---

<div class="hf-hero" markdown>
<span class="hf-kicker">HardFOC tools</span>

# ESP-IDF Project Tools

<p>Shell and Python scripts that build, flash and monitor every app of a multi-app ESP-IDF project. The apps,
ESP-IDF versions, build types and target are written once, in app_config.yml, and the same scripts run
on your machine and in CI.</p>

[Quickstart](quickstart.md){ .md-button .md-button--primary }
[build_app.sh](build-app.md){ .md-button }
[Source on GitHub](https://github.com/hardfoc/hf-espidf-project-tools){ .md-button }
</div>

The scripts live inside your project, usually as a submodule at `examples/esp32/scripts`, next to the
`app_config.yml` they read. Every HardFOC driver, `hf-core` and the board HALs use them for their ESP32 examples,
and [hf-espidf-ci-tools](https://hardfoc.github.io/hf-espidf-ci-tools/) runs them in GitHub Actions.

<!-- figure: tool-map -->
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="diagrams/tool-map.dark.svg">
  <img src="diagrams/tool-map.svg"
    alt="Diagram: app_config.yml is read by config_loader.sh and by the Python scripts generate_matrix.py and
    get_app_info.py; build_app.sh, flash_app.sh, manage_idf.sh and idf_flash_monitor.sh use them;
    build_app.sh runs idf.py into a build folder under builds/; hf-espidf-ci-tools calls
    generate_matrix.py and build_app.sh.">
</picture>
<!-- /figure -->

## The scripts

| Script | What it does | Page |
| --- | --- | --- |
| `build_app.sh` | Builds one app for one build type and ESP-IDF version into its own folder under `builds/` | [build_app.sh](build-app.md) |
| `flash_app.sh` | Flashes, monitors or sizes an app; builds it first when needed; finds the port; logs the monitor | [flash_app.sh](flash-app.md) |
| `manage_idf.sh` | Installs, lists, exports and switches ESP-IDF versions under `~/esp` | [manage_idf.sh](manage-idf.md) |
| `config_loader.sh` | Shell functions that read `app_config.yml`; sourced by the scripts above | [config_loader.sh](config-loader.md) |
| `generate_matrix.py` | Turns `app_config.yml` into a GitHub Actions build matrix | [generate_matrix.py](generate-matrix.md) |
| `get_app_info.py` | Prints an app's source file, the app list, or validates an app name | [get_app_info.py](get-app-info.md) |
| `detect_ports.sh`, `watch_serial_port.sh`, `manage_logs.sh` | Find ESP32 serial ports, watch for plug events, read monitor logs | [Ports and logs](ports-and-logs.md) |
| `setup_repo.sh`, `setup_basic.sh`, `setup_common.sh` | Set up a development machine; create a new project | [Setting up a machine](setup.md) |
| `esp32_completion.sh`, `setup_tab_completion.sh` | Bash completion for `build_app.sh` and `flash_app.sh` | [Tab completion](tab-completion.md) |

## Where to go next

<div class="grid cards" markdown>

-   :material-rocket-launch-outline: **[Quickstart](quickstart.md)**

    ---

    Add the scripts to a project, list one app, build and flash it.

-   :material-file-cog-outline: **[app_config.yml](app-config.md)**

    ---

    Every key, its default and which script reads it.

-   :material-hammer-wrench: **[build_app.sh](build-app.md)**

    ---

    Arguments, build folders, size files and the CMake variables it passes.

-   :material-github: **[Using in CI](ci.md)**

    ---

    The matrix and the build in GitHub Actions.

</div>
