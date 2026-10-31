---
layout: default
title: "CI Pipeline Usage"
description: "Using the ESP-IDF CI pipeline from the separate CI tools repository"
nav_order: 1
parent: "⚡ CI Pipeline"
permalink: /docs/ci-pipeline/
---

# ESP-IDF CI Pipeline Usage

This document explains how to use the ESP-IDF CI pipeline from the separate CI tools repository for automated building and testing of your multi-application ESP-IDF projects.

## 📋 **Overview**

The CI pipeline has been moved to a separate repository: **[hardfoc/hf-espidf-ci-tools](https://github.com/hardfoc/hf-espidf-ci-tools)**

This repository contains the development scripts, while the CI pipeline is maintained separately for better organization and reusability.

## 🚀 **Quick Setup**

### 1. Add CI Workflow to Your Project

Create `.github/workflows/build.yml` in your repository root:

```yaml
name: Build ESP-IDF Applications

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    uses: hardfoc/hf-espidf-ci-tools/.github/workflows/ru-build.yml@main
    with:
      project_dir: "your-esp-idf-project"  # Path to your ESP-IDF project directory
      project_tools_dir: "scripts"  # Path to your scripts directory, maybe [your-esp-idf-project/scripts] or...
      clean_build: false
      auto_clone_tools: true
      max_dec_total: "0"  # Set size budget (0 to disable)
```

### 2. Ensure Project Structure

Your repository should have:
```
your-repository/
├── .github/workflows/      # CI workflows (at repo root)
│   └── build.yml
├── your-esp-idf-project/   # ESP-IDF project directory
│   ├── CMakeLists.txt      # ESP-IDF project root
│   ├── app_config.yml      # Application configuration
│   ├── main/               # Your main application
│   └── components/         # Your components
└── scripts/                # Development scripts (this repo)
    ├── build_app.sh
    ├── flash_app.sh
    ├── generate_matrix.py
    └── ...
```

### 3. Configure Applications

Update your `your-esp-idf-project/app_config.yml` to define your applications:

```yaml
metadata:
  project_name: "Your ESP-IDF Project"
  version: "1.0.0"
  idf_versions: ["release/v5.5"]

apps:
  main_app:
    description: "Main application"
    source_file: "main.cpp"
    build_types: ["Debug", "Release"]
    target: "esp32c6"
  
  test_app:
    description: "Test application"
    source_file: "test_main.cpp"
    build_types: ["Debug"]
    target: "esp32c6"
```

## 🔧 **CI Pipeline Features**

The CI pipeline provides:

- **Matrix Builds**: Parallel builds across multiple ESP-IDF versions, build types, and applications
- **Intelligent Caching**: Python dependencies and build artifacts are cached
- **Size Reporting**: Automatic firmware size analysis and PR comments
- **Size Budgets**: Optional enforcement of firmware size limits
- **Artifact Management**: Automatic upload of build artifacts

## 📊 **Size Reporting**

The CI pipeline automatically generates size reports for pull requests:

| App | IDF | Target | Build | Flash/RAM summary |
|-----|-----|--------|-------|-------------------|
| main_app | v5.5 | esp32c6 | Debug | `text: 12345 data: 678 bss: 90` |
| test_app | v5.5 | esp32c6 | Debug | `text: 9876 data: 543 bss: 45` |

## 🛠️ **Advanced Configuration**

### Size Budget Enforcement

Set a maximum firmware size to fail builds that exceed limits:

```yaml
jobs:
build:
    uses: hardfoc/hf-espidf-ci-tools/.github/workflows/ru-build.yml@main
    with:
      project_dir: "."
      project_tools_dir: "scripts"
      max_dec_total: "1048576"  # 1MB limit
```

### Custom Project Structure

If your project has a different structure:

```yaml
jobs:
  build:
    uses: hardfoc/hf-espidf-ci-tools/.github/workflows/ru-build.yml@main
      with:
      project_dir: "firmware"  # ESP-IDF project in subdirectory
      project_tools_dir: "tools/scripts"  # Scripts in different location
      auto_clone_tools: false  # Don't auto-clone if tools are already present
```

**Important:** The `.github` directory must always be at the repository root, not inside the ESP-IDF project directory.

## 🔗 **Related Documentation**

- **[Build System](/docs/build-system/)** - Understanding the multi-application build system
- **[Configuration](/docs/configuration/)** - Configuring your `app_config.yml`
- **[Getting Started](/docs/getting-started/)** - Setting up your development environment

## 🤝 **Support**

For CI pipeline issues or feature requests, please visit the [CI Tools Repository](https://github.com/hardfoc/hf-espidf-ci-tools/issues).

For development script issues, please use this repository's [Issues](https://github.com/n3b3x/hf-espidf-project-tools/issues).