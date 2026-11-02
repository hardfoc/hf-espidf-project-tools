# Using in CI

How GitHub Actions builds every app with these scripts, through the reusable workflow in hf-espidf-ci-tools.

[hf-espidf-ci-tools](https://hardfoc.github.io/hf-espidf-ci-tools/) `ru-build.yml` runs, for a caller that pins
`@v1`:

1. `generate_matrix.py` (no arguments) for the matrix;
2. for each entry, inside the `espressif/idf:<idf_version_docker>` image,
   `build_app.sh --project-path <project_dir> <app> <build_type> <idf_version>`;
3. an upload of `<project_dir>/build*` (the `builds/` folder) as `fw-<app>-<idf>-<build type>`;
4. on pull requests, a size table from each build's `size.info` and `size.txt`.

The workflow requires `generate_matrix.py`, `build_app.sh` and `config_loader.sh` in the tools folder, and
installs `requirements.txt` when it is there.

## The caller

```yaml
jobs:
  build:
    uses: hardfoc/hf-espidf-ci-tools/.github/workflows/ru-build.yml@v1
    permissions:
      contents: read
      pull-requests: write
    with:
      project_dir: examples/esp32
      project_tools_dir: examples/esp32/scripts
```

Inputs, permissions and failure modes are on the
[ru-build page](https://hardfoc.github.io/hf-espidf-ci-tools/latest/ru-build/).

## Keep the matrix and the build on the same file

The workflow runs `generate_matrix.py` without `--project-path`, so the matrix comes from
`examples/esp32/app_config.yml` (from the repository root) or from `app_config.yml` above the scripts. Keep the
project in `examples/esp32` with the scripts in `examples/esp32/scripts`, the HardFOC layout, and both read the same
file.

## Check locally what CI will build

```bash
python3 examples/esp32/scripts/generate_matrix.py --project-path examples/esp32 --format yaml
./examples/esp32/scripts/build_app.sh combinations
```
