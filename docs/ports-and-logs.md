# Ports and logs

Find the board's serial port, watch it come and go, and read the monitor logs `flash_app.sh --log` writes.

## detect_ports.sh

```bash
./scripts/detect_ports.sh                     # ports that look like ESP32 boards
./scripts/detect_ports.sh --verbose           # with USB details and permissions
./scripts/detect_ports.sh --test-connection   # also open each port
```

It lists candidate ports on Linux and macOS, checks that you can open them and prints the usual fixes (the
`dialout` group, a cable without data lines, a missing USB-to-UART driver, a port held by another program).

## watch_serial_port.sh

Polls `/dev/ttyACM*` and `/dev/ttyUSB*` every `INTERVAL_SEC` seconds (default 2) and prints and logs
`CONNECTED` / `DISCONNECTED` when the set changes, with an `export ESPPORT=...` hint. The log goes to `LOG`
(default `/tmp/hf-vortex-esp-port-watch.log`). Linux device names only.

```bash
INTERVAL_SEC=1 ./scripts/watch_serial_port.sh
```

## idf_flash_monitor.sh

The plain ESP-IDF flow for an existing build, without `flash_app.sh`'s port search and auto-build:

```bash
export ESPPORT=/dev/ttyACM0
./scripts/idf_flash_monitor.sh gpio_test Release            # idf.py -C <project> -B <build> -p $ESPPORT flash monitor
./scripts/idf_flash_monitor.sh gpio_test Release --no-reset # extra arguments go to idf.py
```

It needs `ESPPORT`, an ESP-IDF environment and the build folder (`build_app.sh` first). Without arguments it uses
the app `vortex_led_ws2812_smoke` and `Release`. It honours a per-app `target` in `app_config.yml`.

## manage_logs.sh

Reads the logs in `<project>/logs/`:

| Command | Does |
| --- | --- |
| `list [pattern]` | Every log (names in reverse order) with date, time and size; only names containing `pattern` when given |
| `view <log>` | Shows one log (in `less` on a terminal) |
| `search <pattern>` | Searches every log; prints the first 5 matching lines of each |
| `clean [days]` | Deletes logs older than `days` (default 30) after asking |
| `stats` | Count, total size, oldest and newest, and logs per app |
| `latest` | The last 20 lines of the newest log |
| `tail <log> [lines]` | The last `lines` lines of one log (default 50); add `--follow` to keep printing new lines |
| `grep <log> <pattern>` | Matching lines of one log with line numbers; exit status 1 when nothing matches |

`<log>` is a file name in `<project>/logs/`, or a path when it contains `/`. Patterns are `grep` basic regular
expressions and are case-sensitive. `--no-color` (or the `NO_COLOR` environment variable) turns off colours.
The script uses only commands that behave the same with GNU and BSD tools, so it works on Linux and macOS.
