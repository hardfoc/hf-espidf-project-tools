"""How the scripts fit together around one app_config.yml.

Reads: From top to bottom. app_config.yml in the ESP-IDF project lists the apps, ESP-IDF versions, build types and
target. Two readers parse it: config_loader.sh, which the shell scripts source, and the Python scripts
generate_matrix.py and get_app_info.py. The commands that source config_loader.sh (read from the scripts) sit on
top of them. build_app.sh drives idf.py and writes one build folder per app, build type, target and
ESP-IDF version under builds/. In CI, hf-espidf-ci-tools runs generate_matrix.py and build_app.sh.
"""

import re

from hardfoc_mkdocs_theme.figkit import Fig
from hardfoc_mkdocs_theme.paths import repo_root

ROOT = repo_root()
COMMANDS = ["build_app.sh", "flash_app.sh", "manage_idf.sh", "idf_flash_monitor.sh", "setup_repo.sh",
            "setup_basic.sh", "manage_logs.sh", "detect_ports.sh"]


def data():
    users = [s for s in COMMANDS
             if re.search(r'source\s+"?\$(?:SCRIPT_DIR|script_dir)/config_loader\.sh', (ROOT / s).read_text())]
    return {
        "commands": COMMANDS,
        "sources_config_loader": users,
        "sources": [f"{s}:source config_loader.sh" for s in users],
    }


def build(d):
    f = Fig(
        "tool-map",
        "One configuration file, every script",
        alt="Diagram: app_config.yml is read by config_loader.sh and by the Python scripts generate_matrix.py and "
        "get_app_info.py; build_app.sh, flash_app.sh, manage_idf.sh and idf_flash_monitor.sh use them; build_app.sh "
        "runs idf.py into a build folder under builds/; hf-espidf-ci-tools calls generate_matrix.py and build_app.sh.",
        width=1200,
        kicker="Tools",
        subtitle="Apps, ESP-IDF versions, build types and target are written once, in app_config.yml.",
        profile="overview",
        legend=[("teal", "your project"), ("brand", "this repository"), ("slate", "ESP-IDF and CI")],
    )
    W = f.body_w
    gap = 24
    cfg = f.card(0, 0, W, "app_config.yml", ["metadata (target, idf_versions, build_types), apps, build_config"],
                 tone="teal", accent=True)
    half = (W - gap) / 2
    loader = f.card(0, cfg.b + 40, half, "config_loader.sh", ["sourced by the shell scripts; yq or grep fallback"],
                    tone="brand", accent=True)
    py = f.card(half + gap, cfg.b + 40, half, "generate_matrix.py, get_app_info.py",
                ["CI matrix; source file of an app"], tone="brand", accent=True)
    f.connect(cfg, loader, "bottom", "top", at=0.25)
    f.connect(cfg, py, "bottom", "top", at=0.75)

    top = loader.b + 40
    inner = f.region_inner_top(top)
    ch = f.chips(16, inner, W - 32, d["sources_config_loader"], tone="brand")
    reg = f.region(0, top, W, inner - top + ch + 18, "Commands that read it", tone="brand")
    f.connect(loader, reg, "bottom", "top")
    f.connect(py, reg, "bottom", "top")

    idf = f.card(0, reg.b + 40, half, "idf.py (ESP-IDF in ~/esp)",
                 ["builds/build-app-<app>-type-<build>-target-<t>-idf-<v>"], tone="slate")
    ci = f.card(half + gap, reg.b + 40, half, "hf-espidf-ci-tools ru-build",
                ["generate_matrix.py, then build_app.sh per entry"], tone="slate")
    f.connect(reg, idf, "bottom", "top", at=0.25)
    f.connect(reg, ci, "bottom", "top", at=0.75)
    return f
