#!/bin/bash
# Behaviour tests for manage_idf.sh, manage_logs.sh, config_loader.sh and get_app_info.py.
#
# Plain bash (3.2 or later), no ESP-IDF, network or serial port needed; runs on Linux (GNU tools) and macOS
# (BSD tools). Every test works in its own temporary folder. Exit status is the number of failed tests.
#
#   ./tests/test_scripts.sh            all tests
#   ./tests/test_scripts.sh logs       only tests whose name contains "logs"
#
# get_app_info.py tests need python3 with PyYAML and are skipped without it.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FILTER="${1:-}"
PASSED=0
FAILED=0
SKIPPED=0
FAILED_NAMES=()

# ---------------------------------------------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------------------------------------------

fail() {
    echo "    FAIL: $*"
    return 1
}

# assert_contains <haystack> <needle>
assert_contains() {
    case "$1" in
        *"$2"*) return 0 ;;
    esac
    fail "expected output to contain '$2'"$'\n'"--- output ---"$'\n'"$1"$'\n'"--------------"
}

# assert_not_contains <haystack> <needle>
assert_not_contains() {
    case "$1" in
        *"$2"*)
            fail "expected output not to contain '$2'"$'\n'"--- output ---"$'\n'"$1"$'\n'"--------------"
            return 1
            ;;
    esac
    return 0
}

# assert_eq <actual> <expected>
assert_eq() {
    [ "$1" = "$2" ] || fail "expected '$2', got '$1'"
}

# A project folder with the scripts in <project>/scripts, as the scripts expect
make_project() {
    local project="$1"
    mkdir -p "$project/scripts"
    cp "$ROOT"/*.sh "$ROOT"/*.py "$project/scripts/"
    cat > "$project/app_config.yml" <<'EOF'
---
version: "1.0"
metadata:
  default_app: "gpio_test"
  default_build_type: "Debug"
  target: "esp32c6"
  idf_versions: ["release/v5.5", "release/v5.4"]
  build_types: [["Debug", "Release"], ["Debug"]]

apps:
  gpio_test:
    description: "GPIO test"
    source_file: "GpioTest.cpp"
    category: "peripheral"
    tags: ["gpio", "io"]
  adc_test:
    description: "ADC test"
    source_files: ["AdcTest.cpp", "AdcHelpers.cpp"]
    idf_versions: ["release/v5.4"]
    build_types: ["Release"]
EOF
}

# Set a file's modification time: touch_at <YYYYMMDDhhmm> <file>
touch_at() {
    touch -t "$1" "$2"
}

# A fake yq that answers --version like mikefarah yq v4 and prints "null" for every query, which is what yq
# prints for a key that is not in the file.
make_null_yq() {
    mkdir -p "$1"
    cat > "$1/yq" <<'EOF'
#!/bin/sh
if [ "$1" = "--version" ]; then
    echo "yq (https://github.com/mikefarah/yq/) version v4.44.3"
    exit 0
fi
echo null
EOF
    chmod +x "$1/yq"
}

run_test() {
    local name="$1"
    if [ -n "$FILTER" ] && [[ "$name" != *"$FILTER"* ]]; then
        return 0
    fi
    TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/hf-tools-test.XXXXXX")"
    echo "  $name"
    local status=0
    ( cd "$TEST_TMP" && "$name" ) || status=$?
    rm -rf "$TEST_TMP"
    if [ $status -eq 0 ]; then
        PASSED=$((PASSED + 1))
    elif [ $status -eq 200 ]; then
        echo "    skipped"
        SKIPPED=$((SKIPPED + 1))
    else
        FAILED=$((FAILED + 1))
        FAILED_NAMES+=("$name")
    fi
}

skip() {
    echo "    skip: $*"
    exit 200
}

# ---------------------------------------------------------------------------------------------------------------
# manage_idf.sh: folder names
# ---------------------------------------------------------------------------------------------------------------

test_idf_switch_finds_install_folder_name() {
    export HOME="$TEST_TMP"
    mkdir -p "$HOME/esp/esp-idf-release-v5.5"
    local out
    out=$("$ROOT/manage_idf.sh" switch release/v5.5 2>&1) || fail "switch failed: $out" || return 1
    assert_eq "$(readlink "$HOME/esp/esp-idf")" "$HOME/esp/esp-idf-release-v5.5"
}

test_idf_switch_finds_legacy_underscore_name() {
    export HOME="$TEST_TMP"
    mkdir -p "$HOME/esp/esp-idf-release_v5.4"
    local out
    out=$("$ROOT/manage_idf.sh" switch release/v5.4 2>&1) || fail "switch failed: $out" || return 1
    assert_eq "$(readlink "$HOME/esp/esp-idf")" "$HOME/esp/esp-idf-release_v5.4"
}

test_idf_clean_removes_install_folder_name() {
    export HOME="$TEST_TMP"
    mkdir -p "$HOME/esp/esp-idf-release-v5.5" "$HOME/esp/esp-idf-release-v5.4"
    ln -s "$HOME/esp/esp-idf-release-v5.5" "$HOME/esp/esp-idf"
    local out
    out=$("$ROOT/manage_idf.sh" clean release/v5.4 2>&1) || fail "clean failed: $out" || return 1
    [ ! -d "$HOME/esp/esp-idf-release-v5.4" ] || fail "folder still there"
}

test_idf_clean_refuses_default_version() {
    export HOME="$TEST_TMP"
    mkdir -p "$HOME/esp/esp-idf-release-v5.5"
    ln -s "$HOME/esp/esp-idf-release-v5.5" "$HOME/esp/esp-idf"
    if "$ROOT/manage_idf.sh" clean release/v5.5 >/dev/null 2>&1; then
        fail "clean of the default version succeeded"
        return 1
    fi
    [ -d "$HOME/esp/esp-idf-release-v5.5" ] || fail "default version was removed"
}

test_idf_missing_version_reports_install_folder_name() {
    export HOME="$TEST_TMP"
    mkdir -p "$HOME/esp"
    local out
    if out=$("$ROOT/manage_idf.sh" update release/v5.3 2>&1); then
        fail "update of a missing version succeeded"
        return 1
    fi
    assert_contains "$out" "esp-idf-release-v5.3"
}

test_idf_status_names_both_folder_styles() {
    export HOME="$TEST_TMP"
    mkdir -p "$HOME/esp/esp-idf-release-v5.5" "$HOME/esp/esp-idf-release_v5.4"
    ln -s "$HOME/esp/esp-idf-release_v5.4" "$HOME/esp/esp-idf"
    local out
    out=$("$ROOT/manage_idf.sh" status 2>&1) || fail "status failed: $out" || return 1
    assert_contains "$out" "Default ESP-IDF version: release/v5.4" || return 1
    assert_contains "$out" "release/v5.5" || return 1
    assert_not_contains "$out" "- release_v5.4"
}

test_idf_no_command_prints_usage_and_exits_2() {
    export HOME="$TEST_TMP"
    local out status=0
    out=$("$ROOT/manage_idf.sh" 2>&1) || status=$?
    assert_eq "$status" "2" || return 1
    assert_contains "$out" "No command specified" || return 1
    assert_contains "$out" "Usage: ./manage_idf.sh" || return 1
    assert_not_contains "$out" "command not found"
}

test_idf_unknown_command_exits_2() {
    export HOME="$TEST_TMP"
    local out status=0
    out=$("$ROOT/manage_idf.sh" bogus 2>&1) || status=$?
    assert_eq "$status" "2" || return 1
    assert_contains "$out" "Unknown command: bogus" || return 1
    assert_not_contains "$out" "command not found"
}

test_idf_help_exits_0() {
    local out
    out=$("$ROOT/manage_idf.sh" --help) || fail "--help exited non-zero" || return 1
    assert_contains "$out" "Usage: ./manage_idf.sh"
}

# ---------------------------------------------------------------------------------------------------------------
# config_loader.sh: build_config defaults and the portable mtime sort
# ---------------------------------------------------------------------------------------------------------------

test_config_missing_patterns_with_yq_use_defaults() {
    make_project "$TEST_TMP/proj"
    make_null_yq "$TEST_TMP/bin"
    local out
    out=$(PATH="$TEST_TMP/bin:$PATH" PROJECT_PATH="$TEST_TMP/proj" bash -c '
        source "$1/config_loader.sh"
        get_build_directory gpio_test Debug esp32c6 release/v5.5
        get_project_name gpio_test' _ "$ROOT" 2>/dev/null)
    assert_eq "$out" "$TEST_TMP/proj/builds/build-app-gpio_test-type-Debug-target-esp32c6-idf-release_v5_5
esp32_iid_gpio_test_app"
}

test_config_without_yq_uses_defaults() {
    make_project "$TEST_TMP/proj"
    local out
    out=$(PROJECT_PATH="$TEST_TMP/proj" bash -c '
        source "$1/config_loader.sh"
        check_yq() { return 1; }
        get_build_directory gpio_test Release esp32c6 release/v5.4' _ "$ROOT" 2>/dev/null)
    assert_eq "$out" "$TEST_TMP/proj/builds/build-app-gpio_test-type-Release-target-esp32c6-idf-release_v5_4"
}

test_config_sort_paths_by_mtime_desc() {
    make_project "$TEST_TMP/proj"
    mkdir -p "$TEST_TMP/b/build-old" "$TEST_TMP/b/build-new" "$TEST_TMP/b/build-mid"
    touch_at 202401010000 "$TEST_TMP/b/build-old"
    touch_at 202403010000 "$TEST_TMP/b/build-new"
    touch_at 202402010000 "$TEST_TMP/b/build-mid"
    local out
    out=$(PROJECT_PATH="$TEST_TMP/proj" bash -c '
        source "$1/config_loader.sh"
        find "$2" -maxdepth 1 -type d -name "build-*" | sort_paths_by_mtime_desc' _ "$ROOT" "$TEST_TMP/b" 2>/dev/null)
    assert_eq "$out" "$TEST_TMP/b/build-new
$TEST_TMP/b/build-mid
$TEST_TMP/b/build-old"
}

test_no_gnu_only_find_printf_or_stat_c() {
    # find -printf and a bare stat -c fail on macOS; stat -c is fine only with a stat -f fallback.
    local hits code
    code=$(grep -n -e 'find .*-printf' -e 'stat -c' "$ROOT"/*.sh | grep -v -E '^[^:]+:[0-9]+:[[:space:]]*#' || true)
    hits=$(echo "$code" | grep -e 'find .*-printf' || true)
    [ -z "$hits" ] || fail "find -printf in: $hits" || return 1
    hits=$(echo "$code" | grep -e 'stat -c' | grep -v 'stat -f' || true)
    [ -z "$hits" ] || fail "stat -c without stat -f fallback in: $hits"
}

# ---------------------------------------------------------------------------------------------------------------
# manage_logs.sh
# ---------------------------------------------------------------------------------------------------------------

make_logs() {
    make_project "$TEST_TMP/proj"
    mkdir -p "$TEST_TMP/proj/logs"
    LOGS="$TEST_TMP/proj/logs"
    printf 'boot\nE (120) gpio: boom\nI (130) done\n' > "$LOGS/gpio_test_Release_20240101_000000.log"
    printf 'adc line 1\nadc line 2\nadc line 3\n' > "$LOGS/adc_test_Debug_20240201_000000.log"
    touch_at 202401010930 "$LOGS/gpio_test_Release_20240101_000000.log"
    touch_at 202402011015 "$LOGS/adc_test_Debug_20240201_000000.log"
    LOGS_SH="$TEST_TMP/proj/scripts/manage_logs.sh"
}

test_logs_list_shows_dates_and_times() {
    make_logs
    local out
    out=$("$LOGS_SH" list --no-color 2>&1) || fail "list failed: $out" || return 1
    assert_contains "$out" "2024-01-01" || return 1
    assert_contains "$out" "09:30:00" || return 1
    assert_contains "$out" "2024-02-01" || return 1
    assert_not_contains "$out" "Unknown"
}

test_logs_list_filters_by_pattern() {
    make_logs
    local out
    out=$("$LOGS_SH" list gpio --no-color 2>&1) || fail "list failed: $out" || return 1
    assert_contains "$out" "gpio_test_Release" || return 1
    assert_not_contains "$out" "adc_test"
}

test_logs_latest_picks_newest() {
    make_logs
    local out
    out=$("$LOGS_SH" latest --no-color 2>&1) || fail "latest failed: $out" || return 1
    assert_contains "$out" "Latest log file: adc_test_Debug_20240201_000000.log" || return 1
    assert_contains "$out" "adc line 3"
}

test_logs_stats_oldest_newest_and_size() {
    make_logs
    local out
    out=$("$LOGS_SH" stats --no-color 2>&1) || fail "stats failed: $out" || return 1
    assert_contains "$out" "Total log files: 2" || return 1
    assert_contains "$out" "Total size: 70 bytes" || return 1
    assert_contains "$out" "Oldest log: gpio_test_Release_20240101_000000.log (2024-01-01)" || return 1
    assert_contains "$out" "Newest log: adc_test_Debug_20240201_000000.log (2024-02-01)"
}

test_logs_search() {
    make_logs
    local out
    out=$("$LOGS_SH" search boom --no-color 2>&1) || fail "search failed: $out" || return 1
    assert_contains "$out" "Found 1 match(es) in: gpio_test_Release_20240101_000000.log" || return 1
    assert_not_contains "$out" "integer expression"
}

test_logs_tail() {
    make_logs
    local out
    out=$("$LOGS_SH" tail adc_test_Debug_20240201_000000.log 2 2>&1) || fail "tail failed: $out" || return 1
    assert_eq "$out" "adc line 2
adc line 3"
}

test_logs_grep() {
    make_logs
    local out
    out=$("$LOGS_SH" grep gpio_test_Release_20240101_000000.log "E (" 2>&1) || fail "grep failed: $out" || return 1
    assert_eq "$out" "2:E (120) gpio: boom" || return 1
    if "$LOGS_SH" grep gpio_test_Release_20240101_000000.log nothing-here --no-color >/dev/null 2>&1; then
        fail "grep without a match exited 0"
    fi
}

test_logs_no_color() {
    make_logs
    local out
    out=$("$LOGS_SH" list --no-color 2>&1)
    assert_not_contains "$out" $'\033[' || return 1
    out=$(NO_COLOR=1 "$LOGS_SH" list 2>&1)
    assert_not_contains "$out" $'\033['
}

test_logs_help_lists_only_implemented_commands() {
    local help cmd
    help=$("$ROOT/manage_logs.sh" --help)
    assert_not_contains "$help" "--verbose" || return 1
    for cmd in list view search clean stats latest tail grep; do
        assert_contains "$help" "  $cmd" || return 1
        grep -q "\"$cmd\")" "$ROOT/manage_logs.sh" || fail "help lists $cmd, script has no case for it" || return 1
    done
}

# ---------------------------------------------------------------------------------------------------------------
# get_app_info.py
# ---------------------------------------------------------------------------------------------------------------

need_pyyaml() {
    python3 -c 'import yaml' 2>/dev/null || skip "python3 with PyYAML not available"
}

app_info() {
    python3 "$ROOT/get_app_info.py" "$@" --project-path "$TEST_TMP/proj"
}

test_app_info_every_help_command_is_implemented() {
    need_pyyaml
    make_project "$TEST_TMP/proj"
    local cmds cmd out
    cmds=$(python3 "$ROOT/get_app_info.py" --help | sed -n '/^COMMANDS:/,/^$/p' | awk 'NR > 1 && NF {print $1}')
    [ -n "$cmds" ] || fail "no commands found in --help" || return 1
    for cmd in $cmds; do
        out=$(app_info "$cmd" gpio_test 2>&1) || fail "$cmd exited non-zero: $out" || return 1
        assert_not_contains "$out" "Unknown command" || return 1
    done
}

test_app_info_values() {
    need_pyyaml
    make_project "$TEST_TMP/proj"
    assert_eq "$(app_info source_file adc_test)" "AdcTest.cpp" || return 1
    assert_eq "$(app_info list)" "gpio_test adc_test" || return 1
    assert_eq "$(app_info idf_versions gpio_test)" "release/v5.5 release/v5.4" || return 1
    assert_eq "$(app_info build_types gpio_test)" "release/v5.5: Debug Release
release/v5.4: Debug" || return 1
    assert_eq "$(app_info build_types adc_test)" "release/v5.4: Release" || return 1
    assert_eq "$(app_info tags gpio_test)" "gpio io" || return 1
    assert_eq "$(app_info category gpio_test)" "peripheral" || return 1
    assert_eq "$(app_info category adc_test)" "" || return 1
    assert_eq "$(app_info dependencies gpio_test --format json)" "null"
}

test_app_info_json() {
    need_pyyaml
    make_project "$TEST_TMP/proj"
    local out
    out=$(app_info info adc_test --format json) || fail "info failed" || return 1
    python3 -c '
import json, sys
d = json.loads(sys.argv[1])
assert d["name"] == "adc_test", d
assert d["idf_versions"] == ["release/v5.4"], d
assert d["build_types"] == {"release/v5.4": ["Release"]}, d
' "$out" || fail "unexpected json: $out"
}

test_app_info_unknown_app() {
    need_pyyaml
    make_project "$TEST_TMP/proj"
    if app_info info nope >/dev/null 2>&1; then
        fail "info of an unknown app exited 0"
        return 1
    fi
    assert_eq "$(app_info validate nope 2>/dev/null)" "false"
}

# ---------------------------------------------------------------------------------------------------------------

echo "Running script tests on $(uname -s) with bash ${BASH_VERSION}"
for t in $(declare -F | awk '{print $3}' | grep '^test_'); do
    run_test "$t"
done

echo ""
echo "Passed: $PASSED  Failed: $FAILED  Skipped: $SKIPPED"
if [ $FAILED -gt 0 ]; then
    printf '  failed: %s\n' "${FAILED_NAMES[@]}"
fi
exit $FAILED
