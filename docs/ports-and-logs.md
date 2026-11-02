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
| `list` | Every log (names in reverse order) with date, time and size |
| `view <log>` | Shows one log |
| `search <pattern>` | Searches every log |
| `clean [days]` | Deletes logs older than `days` (default 30) |
| `stats` | Count, total size and logs per app |
| `latest` | The last 20 lines of the newest log |

The script's `--help` also mentions `tail`, `grep`, `--follow`, `--verbose` and `--no-color`; they are not
implemented. `latest` uses GNU `find -printf` and `list` uses GNU `stat -c`, so on macOS `latest` prints nothing and
`list` shows no dates.
