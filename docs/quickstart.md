# Quickstart

Add the scripts to an ESP-IDF project, describe one app and build and flash it.

You need git, Python 3 with PyYAML, and either an installed ESP-IDF or the network access to let the scripts
install one (see [Setting up a machine](setup.md)). `yq` is optional; without it the scripts parse
`app_config.yml` with `grep` and `sed` and a few features fall back to defaults
([config_loader.sh](config-loader.md#yq-or-the-fallback-parser)).

<div class="hf-steps" markdown>

1. **Add the scripts** next to the project, as a submodule:

    ```bash
    cd examples/esp32                       # the folder with the project's CMakeLists.txt
    git submodule add https://github.com/hardfoc/hf-espidf-project-tools.git scripts
    ```

    The scripts take the folder above them as the project. To keep them elsewhere, pass `--project-path`; see
    [Project layout](project-layout.md).

2. **Describe the apps** in `app_config.yml` beside `CMakeLists.txt`:

    ```yaml
    ---
    version: "1.0"
    metadata:
      default_app: "gpio_test"
      default_build_type: "Debug"
      target: "esp32c6"
      idf_versions: ["release/v5.5"]
      build_types: [["Debug", "Release"]]

    apps:
      gpio_test:
        description: "GPIO self-test"
        source_file: "GpioTest.cpp"
        ci_enabled: true
        featured: true

    build_config:
      build_directory_pattern: "build-app-{app_type}-type-{build_type}-target-{target}-idf-{idf_version}"
      project_name_pattern: "esp32_{app_type}_app"
    ```

3. **Compile the app's source file.** `build_app.sh` passes `APP_TYPE`, `BUILD_TYPE` and `APP_SOURCE_FILE` to
   CMake. The `main` component registers the one file:

    ```cmake title="main/CMakeLists.txt"
    idf_component_register(SRCS "${APP_SOURCE_FILE}" REQUIRES driver freertos log)
    ```

    The full contract, including the requirements phase where these variables are not yet set, is in
    [Project layout](project-layout.md#what-cmake-receives).

4. **Build:**

    ```bash
    ./scripts/build_app.sh gpio_test Debug
    ```

    The firmware lands in `builds/build-app-gpio_test-type-Debug-target-esp32c6-idf-release_v5_5/`, with
    `size.txt` and `size.info` beside it.

5. **Flash and monitor** (the port is found automatically; `Ctrl+]` leaves the monitor):

    ```bash
    ./scripts/flash_app.sh gpio_test Debug
    ```

</div>

!!! tip "See what is configured"
    `./scripts/build_app.sh list` prints the apps, build types and ESP-IDF versions;
    `./scripts/build_app.sh combinations` prints every allowed app, build type and version combination.

Next: [app_config.yml](app-config.md), every key and who reads it.
