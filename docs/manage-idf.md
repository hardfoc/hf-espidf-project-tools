# manage_idf.sh

Install, list, export and switch the ESP-IDF versions that `app_config.yml` asks for.

```bash
./scripts/manage_idf.sh <command> [version] [--force] [--project-path <path>]
```

## Commands

| Command | Does |
| --- | --- |
| `install [--force]` | Clones every version in `metadata.idf_versions` into `~/esp/esp-idf-<version>` (with submodules), runs `install.sh esp32c6`, and points `~/esp/esp-idf` at the first. `--force` deletes and re-clones existing ones |
| `list` | The versions installed under `~/esp` |
| `export <version>` | Sources that version's `export.sh` in the script's own shell |
| `switch <version>` | Points the `~/esp/esp-idf` symlink at the version |
| `update <version>` | `git pull` the version and its submodules, then `install.sh esp32c6` |
| `clean <version>` | Deletes the version's folder |
| `status` | The current ESP-IDF environment |

The folder name replaces every character other than letters, digits, `.`, `_` and `-` with `-`:
`release/v5.5` is installed in `~/esp/esp-idf-release-v5.5`. Tools go to `~/.espressif/` as usual.

!!! warning "switch, update and clean use a different folder name"
    These three commands look for `~/esp/esp-idf-release_v5.5` (`/` replaced by `_`) while `install`,
    `build_app.sh` and `setup_basic.sh` create `~/esp/esp-idf-release-v5.5`. On a machine set up by this
    repository they report the version as not installed; switch or remove the folder by hand until this is
    fixed.

## Using an installed version

`build_app.sh` exports the right version itself when `idf.py` is not on the `PATH`. In an interactive shell,
source the version directly:

```bash
. ~/esp/esp-idf-release-v5.5/export.sh
```

`export` runs in a child process, so it cannot change the calling shell.

!!! note "Tools are installed for esp32c6"
    `install` and `update` run `install.sh esp32c6` whatever `metadata.target` says. For another chip, run
    `install.sh <target>` in the version's folder once.
