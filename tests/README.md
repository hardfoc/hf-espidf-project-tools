# ESP32 Scripts Tests

This directory contains test scripts and utilities for validating the ESP32 build and flash scripts functionality.

## Test Scripts

### `test_scripts.sh`
Behaviour tests for `manage_idf.sh`, `manage_logs.sh`, `config_loader.sh` and `get_app_info.py`. Needs only
bash (3.2 or later); the `get_app_info.py` tests also need `python3` with PyYAML. Runs in CI on Ubuntu and macOS
(`.github/workflows/script-tests.yml`, called by `ci-docs-publish.yml` and required by its CI gate).

**Usage:**
```bash
./tests/test_scripts.sh          # all tests
./tests/test_scripts.sh logs     # only tests whose name contains "logs"
```

### `test_tab_completion.sh`
Comprehensive test suite for the ESP32 tab completion system.

**Features:**
- Tests auto-installation mechanism
- Validates app type discovery from project structure
- Tests build type detection
- Verifies serial port discovery
- Simulates completion behavior
- Checks .bashrc integration

**Usage:**
```bash
cd examples/esp32/scripts/tests
./test_tab_completion.sh
```

### `demo_tab_completion.sh`
Interactive demonstration of the auto-installing tab completion feature.

**Features:**
- Shows current completion state
- Demonstrates auto-installation process
- Provides example usage commands
- Shows real completion results

**Usage:**
```bash
cd examples/esp32/scripts/tests  
./demo_tab_completion.sh
```

## Running Tests

### Quick Test
```bash
# Run just the tab completion tests
cd examples/esp32/scripts/tests
./test_tab_completion.sh
```

### Interactive Demo
```bash
# See the auto-installation in action
cd examples/esp32/scripts/tests
./demo_tab_completion.sh
```

## Test Coverage

The test suite validates:

- ✅ **Script Loading** - Completion functions register correctly
- ✅ **App Discovery** - Finds actual apps from project structure
- ✅ **Build Types** - Detects Debug/Release from build scripts
- ✅ **Serial Ports** - Auto-discovers available ports
- ✅ **Completion Logic** - Simulates TAB TAB behavior
- ✅ **Persistence** - Checks .bashrc integration

## Expected Results

When running the test suite, you should see:
```
🎯 Core Functionality Tests:
   ✅ Auto-installation mechanism
   ✅ App type discovery (with fallbacks)  
   ✅ Build type discovery
   ✅ Serial port discovery
   ✅ Completion simulation
   ✅ Configuration check

🎉 All tests PASSED! Tab completion is ready to use.
```

## Troubleshooting Tests

If tests fail:

1. **Check permissions**: Ensure test scripts are executable
   ```bash
   chmod +x *.sh
   ```

2. **Check bash version**: Completion requires bash 4.0+
   ```bash
   bash --version
   ```

3. **Check script paths**: Tests assume they're in `scripts/tests/`
4. **Check dependencies**: Requires bash-completion package on some systems

## Adding New Tests

To add new test cases:

1. Add test function to `test_tab_completion.sh`
2. Follow naming convention: `test_feature_name()`
3. Return 1 on failure, 0 on success
4. Add to test execution list in main script
5. Update this README with new test description