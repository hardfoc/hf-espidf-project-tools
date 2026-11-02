# Tab completion

Complete app names, build types, operations and ports for `build_app.sh` and `flash_app.sh` in Bash.

```bash
./scripts/setup_tab_completion.sh       # adds a source line to ~/.bashrc
source ~/.bashrc
./scripts/build_app.sh gp<Tab>          # gpio_test
```

`esp32_completion.sh` defines the completion functions and registers them for `build_app.sh`, `./build_app.sh`,
`scripts/build_app.sh` and `./scripts/build_app.sh` (and the same for `flash_app.sh`). It reads the app names and
build types from the project's `app_config.yml` and the ports from `/dev`. To try it without changing
`~/.bashrc`, source it in the current shell:

```bash
source ./scripts/esp32_completion.sh
```

`tests/test_tab_completion.sh` checks the installation and the completions; see [Testing and CI](testing.md).
