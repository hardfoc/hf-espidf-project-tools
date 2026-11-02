# HardFOC ESP-IDF Project Tools

![Scripts](https://img.shields.io/badge/Scripts-Development%20Tools-blue?logo=bash)
[![ESP-IDF](https://img.shields.io/badge/ESP--IDF-Multi%20App%20Builds-green?logo=espressif&logoColor=white)](https://docs.espressif.com/projects/esp-idf/en/latest/)
![Configuration](https://img.shields.io/badge/Config-YAML%20Based-purple?logo=yaml)

**Development scripts for ESP-IDF projects with multiple applications**

> **📋 Important**: These tools are designed to be **integrated into your ESP-IDF project**, not used as standalone applications.

**🌐 [Live Documentation](https://hardfoc.github.io/hf-espidf-project-tools/)** 

---

## **What This Is**

Development scripts that enhance ESP-IDF projects with:
- **Multi-application builds** from a single project
- **YAML-based configuration** management
- **Automated CI/CD integration** patterns
- **Cross-platform port detection** and flashing

## **Quick Start**

### **Integration Methods**

Choose the best method for your ESP-IDF project:

#### **Method 1: Submodule Integration (Recommended)**
```bash
# Navigate to your ESP-IDF project
cd your-esp-idf-project

# Add tools as submodule
git submodule add https://github.com/hardfoc/hf-espidf-project-tools.git scripts

# Your project structure:
# your-esp-idf-project/
# ├── CMakeLists.txt
# ├── app_config.yml
# ├── main/
# └── scripts/                    # Project tools
#     ├── build_app.sh
#     └── flash_app.sh

# Start building
./scripts/build_app.sh your_app Release
```

#### **Method 2: Direct Clone Integration**
```bash
# Navigate to your ESP-IDF project
cd your-esp-idf-project

# Clone tools directly
git clone https://github.com/hardfoc/hf-espidf-project-tools.git scripts

# Start building
./scripts/build_app.sh your_app Release
```

#### **Method 3: Shared Tools Directory**
```bash
# For multiple projects, use shared tools
mkdir -p ~/shared-esp32-tools
cd ~/shared-esp32-tools
git clone https://github.com/hardfoc/hf-espidf-project-tools.git .

# In each ESP-IDF project, use --project-path
cd your-esp-idf-project
~/shared-esp32-tools/build_app.sh --project-path . your_app Release
```

## **Project Structure Concepts**

### **Project Directory (`project_dir`)**
- **Purpose**: Points to your ESP-IDF project directory (contains `CMakeLists.txt`, `app_config.yml`)
- **Examples**: `examples/esp32`, `firmware/esp32-project`, `src/esp32-app`

### **Tools Directory (`project_tools_dir`)**
- **Purpose**: Points to directory containing the build scripts (`build_app.sh`, `generate_matrix.py`, etc.)
- **Auto-detection**: If not specified, looks for `hf-espidf-project-tools` subdirectory in project directory
- **Multi-Project Support**: Can be shared across multiple projects since all scripts accept `--project-path` argument
- **Examples**: `examples/esp32/scripts`, `examples/esp32/hf-espidf-project-tools`, `tools/esp32-build-scripts`, `shared-tools`

## **Common Integration Patterns**

### **Pattern 1: Submodule Setup (Recommended)**
```bash
# Repository structure:
# your-repo/
# ├── examples/esp32/           # ESP-IDF project
# │   ├── CMakeLists.txt
# │   ├── app_config.yml
# │   └── hf-espidf-project-tools/  # Submodule containing project tools
# │       ├── build_app.sh
# │       └── generate_matrix.py

# CI/CD Usage:
jobs:
  build:
    uses: hardfoc/hf-espidf-ci-tools/.github/workflows/ru-build.yml@v1
    with:
      project_dir: examples/esp32
      project_tools_dir: examples/esp32/hf-espidf-project-tools  # Points to submodule
```

### **Pattern 2: Direct Clone Setup**
```bash
# Repository structure:
# your-repo/
# ├── examples/esp32/           # ESP-IDF project
# │   ├── CMakeLists.txt
# │   ├── app_config.yml
# │   └── hf-espidf-project-tools/  # Cloned directly
# │       ├── build_app.sh
# │       └── generate_matrix.py

# CI/CD Usage:
jobs:
  build:
    uses: hardfoc/hf-espidf-ci-tools/.github/workflows/ru-build.yml@v1
    with:
      project_dir: examples/esp32
      # project_tools_dir not needed - auto-detects hf-espidf-project-tools
```

### **Pattern 3: Custom Tools Location**
```bash
# Repository structure:
# your-repo/
# ├── firmware/esp32/           # ESP-IDF project
# │   ├── CMakeLists.txt
# │   └── app_config.yml
# └── build-tools/              # Custom tools location
#     ├── build_app.sh
#     └── generate_matrix.py

# CI/CD Usage:
jobs:
  build:
    uses: hardfoc/hf-espidf-ci-tools/.github/workflows/ru-build.yml@v1
    with:
      project_dir: firmware/esp32
      project_tools_dir: build-tools
```

### **Pattern 4: Shared Tools for Multiple Projects**
```bash
# Repository structure:
# your-repo/
# ├── projects/
# │   ├── project-a/            # ESP-IDF project A
# │   │   ├── CMakeLists.txt
# │   │   └── app_config.yml
# │   └── project-b/            # ESP-IDF project B
# │       ├── CMakeLists.txt
# │       └── app_config.yml
# └── shared-tools/             # Shared tools directory
#     ├── build_app.sh
#     └── generate_matrix.py

# CI/CD Usage:
jobs:
  build-project-a:
    uses: hardfoc/hf-espidf-ci-tools/.github/workflows/ru-build.yml@v1
    with:
      project_dir: projects/project-a
      project_tools_dir: shared-tools  # Shared across all projects
      
  build-project-b:
    uses: hardfoc/hf-espidf-ci-tools/.github/workflows/ru-build.yml@v1
    with:
      project_dir: projects/project-b
      project_tools_dir: shared-tools  # Same shared tools directory
```

## **Core Scripts**

| Script | Purpose | Usage |
|--------|---------|-------|
| `build_app.sh` | Build applications | `./scripts/build_app.sh app_name build_type` |
| `flash_app.sh` | Flash and monitor | `./scripts/flash_app.sh flash_monitor app_name` |
| `generate_matrix.py` | CI matrix generation | `python3 scripts/generate_matrix.py` |
| `config_loader.sh` | Configuration utilities | Source for other scripts |

## **Configuration**

All scripts use `app_config.yml` for configuration:

```yaml
metadata:
  idf_versions: ["release/v5.5", "release/v5.4"]
  build_types: [["Debug", "Release"], ["Debug", "Release"]]
  target: "esp32c6"

apps:
  gpio_test:
    ci_enabled: true
    description: "GPIO peripheral testing"
    idf_versions: ["release/v5.5"]
    build_types: [["Debug", "Release"]]
```

## **CI/CD Integration**

Works with the [ESP-IDF CI Tools](https://github.com/hardfoc/hf-espidf-ci-tools) for automated builds:

```yaml
- name: Build ESP-IDF Applications
  uses: hardfoc/hf-espidf-ci-tools/.github/workflows/ru-build.yml@v1
  with:
    project_dir: examples/esp32
    project_tools_dir: examples/esp32/scripts
```

## **Documentation**

- **[Getting Started](https://hardfoc.github.io/hf-espidf-project-tools/docs/getting-started/)** - Quick start guide
- **[CI Integration Patterns](https://hardfoc.github.io/hf-espidf-project-tools/docs/ci-integration-patterns/)** - CI/CD patterns
- **[Build System](https://hardfoc.github.io/hf-espidf-project-tools/docs/build-system/)** - Build management
- **[Configuration](https://hardfoc.github.io/hf-espidf-project-tools/docs/configuration/)** - YAML configuration
- **[Examples](https://hardfoc.github.io/hf-espidf-project-tools/docs/examples/)** - Real-world examples

## **Testing**

- **[Test Scripts](tests/)** - Test suite for script functionality
  - `test_tab_completion.sh` - Comprehensive tab completion tests
  - `demo_tab_completion.sh` - Interactive tab completion demo

## **Contributing**

Contributions welcome! See our [Contributing Guide](https://hardfoc.github.io/hf-espidf-project-tools/docs/contributing/) for details.

## **License**

This project is licensed under the GPL-3.0 License - see the [LICENSE](./LICENSE) file for details.
