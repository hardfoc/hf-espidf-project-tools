# Testing and CI

What checks this repository, and how to run the tests.

## Tests

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
| `ci-docs-publish.yml` | Strict site build, generated tables and figure drift, link check, Lighthouse; publishes the site from `main`; a single `CI gate` check |
| `yamllint.yml` | YAML style (`.yamllint`, strict) |

Both call the versioned workflows of [hf-general-ci-tools](https://github.com/hardfoc/hf-general-ci-tools)
at `@v1`. After editing an argument of `generate_matrix.py` or `get_app_info.py`, refresh the tables on this
site:

```bash
hardfoc-docs gen
```
