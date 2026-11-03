# Testing and CI

What checks this repository, and how to run the tests.

## Tests

`tests/test_scripts.sh` checks the scripts' behaviour without ESP-IDF, network or a board: the ESP-IDF folder
names `manage_idf.sh` uses, every `manage_logs.sh` command, the `build_config` defaults in `config_loader.sh`, every
`get_app_info.py` command, and that no script relies on GNU-only `find -printf` or `stat -c`. Each test runs in its
own temporary folder (with `HOME` pointed there for `manage_idf.sh`). It needs only bash 3.2 or later; the
`get_app_info.py` tests also need `python3` with PyYAML and are skipped without it.

```bash
./tests/test_scripts.sh          # all tests; exit status is the number of failures
./tests/test_scripts.sh logs     # only tests whose name contains "logs"
```

`tests/test_tab_completion.sh` checks the tab completion: installation into `~/.bashrc`, app and build-type
discovery from `app_config.yml`, port discovery and simulated completions. `tests/demo_tab_completion.sh`
shows the completions interactively. Both expect the scripts inside a project (`examples/esp32/scripts`).

```bash
cd examples/esp32/scripts/tests
./test_tab_completion.sh
```

The build and flash scripts are exercised by every repository that builds its ESP32 examples in CI through
[hf-espidf-ci-tools](ci.md).

## CI workflows

| Workflow | Checks |
| --- | --- |
| `ci-docs-publish.yml` | Strict site build, generated tables and figure drift, link check, Lighthouse; publishes the site from `main`; runs `script-tests.yml`; a single `CI gate` check that fails when the docs or the script tests fail |
| `script-tests.yml` | `tests/test_scripts.sh` on Ubuntu (GNU tools) and macOS (BSD tools, bash 3.2). Called by `ci-docs-publish.yml`: always on `main`, and on pull requests that change a `.sh` or `.py` file, `tests/` or a workflow; otherwise skipped, which the gate accepts |
| `yamllint.yml` | YAML style (`.yamllint`, strict) |

`ci-docs-publish.yml` and `yamllint.yml` call the versioned workflows of [hf-general-ci-tools](https://github.com/hardfoc/hf-general-ci-tools)
at `@v1`. After editing an argument of `generate_matrix.py` or `get_app_info.py`, refresh the tables on this
site:

```bash
hardfoc-docs gen
```
