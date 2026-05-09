#!/usr/bin/env python3
import re
import sys
import subprocess

def run_git_command(args):
    result = subprocess.run(args, capture_output=True, text=True)
    return result.stdout.strip() if result.stdout else ""

with open("CHANGELOG.md", "r", encoding="utf-8") as f:
    content = f.read()

def extract_latest_changelog():
    pattern = r"## (.*?)(?=## |$)"
    match = re.search(pattern, content, re.DOTALL)
    
    if match:
        full_content = match.group(0).strip()
        parts = full_content.split('\n', 1)
        if len(parts) > 1:
            return parts[1].strip()
        else:
            return full_content
    return None

def extract_version_changelog(version):
    version_clean = version.lstrip('Nv')
    pattern = rf"(?:^## {re.escape(version_clean)}\s*\n)(.*?)(?=^## |\Z)"
    match = re.search(pattern, content, re.DOTALL | re.MULTILINE)
    
    if match:
        return match.group(1).strip()
    return None

input_version = sys.argv[1] if len(sys.argv) > 1 else None

if input_version and (input_version.startswith('Nv') or re.match(r'^\d+\.\d+', input_version)):
    changelog = extract_version_changelog(input_version)
    version_for_compare = input_version if input_version.startswith('Nv') else f'Nv{input_version}'
else:
    changelog = extract_latest_changelog()
    version_for_compare = "simple-native"

if changelog:
    print(changelog)
    
    try:
        if input_version and (input_version.startswith('Nv') or re.match(r'^\d+\.\d+', input_version)):
            last_tag = run_git_command(["git", "describe", "--abbrev=0", "--tags", f"{version_for_compare}^"])
            if not last_tag:
                last_tag = run_git_command(["git", "describe", "--abbrev=0", "--tags"])
        else:
            last_tag = run_git_command(["git", "describe", "--abbrev=0", "--tags"])
    except:
        last_tag = run_git_command(["git", "describe", "--abbrev=0", "--tags"])
    
    if not last_tag:
        last_tag = "Nv1.0.0"
    
    print(f"\n修改记录：[{last_tag} -> {version_for_compare}](https://github.com/SageMik/sqlite3_simple/compare/{last_tag}...{version_for_compare})")
else:
    if input_version:
        print(f"未找到版本 {input_version} 的 CHANGELOG")
    else:
        print("未找到 CHANGELOG 内容")
