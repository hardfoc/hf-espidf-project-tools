# flash_app.sh

Flash an app to a board and open the serial monitor, building it first when no build exists.

```bash
./scripts/flash_app.sh [operation] [app] [build_type] [idf_version] [options]
./scripts/flash_app.sh [app] [build_type] [idf_version] [operation] [options]
```

## Operations

| Operation | Does |
| --- | --- |
| `flash_monitor` (default) | `idf.py flash monitor` with the app's build folder |
| `flash` | Flash only |
| `monitor` | Monitor only; uses the newest build folder for symbol decoding when there is one |
| `size` | `idf.py size`, `size-components` and a JSON memory summary of an existing build |
| `list` | The apps, build types and ESP-IDF versions |
| `ports` | The serial ports that look like ESP32 boards |

The operation can be the first or the last word. Missing app, build type and version come from
`metadata.default_app`, `metadata.default_build_type` and the first entry of `metadata.idf_versions`.

## Options

| Option | Environment | Effect |
| --- | --- | --- |
| `--port <dev>`, `-p <dev>` | `ESPPORT` | Serial port; the flag wins over the variable |
| `--log [name]` | | Copy the monitor output to `<project>/logs/<name>_<timestamp>.log` (default name `<app>_<build_type>` or `monitor`) |
| `--project-path <path>` | `PROJECT_PATH` | The project directory |
| `-h`, `--help` | | Usage |

## Finding the port

Without `--port` or `ESPPORT` the script looks for `/dev/ttyACM*` and `/dev/ttyUSB*` on Linux, and
`/dev/cu.usbmodem*`, `/dev/cu.usbserial*`, `/dev/cu.SLAB_USBtoUART*`, `/dev/cu.CP210*`, `/dev/cu.CH340*` (then the
`/dev/tty.*` equivalents) on macOS. One port is used directly; with several it asks which one, and takes the first
after 30 seconds. `./scripts/flash_app.sh ports` and [detect_ports.sh](ports-and-logs.md#detect_portssh) show what
it finds.

## Building first

Before flashing, the script checks for `<build folder>/<project_name>.bin`. When it is missing it deletes the
incomplete folder and runs `build_app.sh <app> <build_type>`; that build uses the default ESP-IDF version for the
build type, not an `idf_version` given to `flash_app.sh`.

## Examples

```bash
./scripts/flash_app.sh gpio_test Release                      # build if needed, flash, monitor
./scripts/flash_app.sh flash gpio_test Debug --port /dev/ttyACM1
./scripts/flash_app.sh monitor --log bring_up                 # monitor only, logged
ESPPORT=/dev/cu.usbmodem101 ./scripts/flash_app.sh gpio_test Debug
```

Leave the monitor with `Ctrl+]`.
