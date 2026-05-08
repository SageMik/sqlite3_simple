#!/usr/bin/env python3
import re
import sys
import subprocess

def run_git_command(args):
    result = subprocess.run(args, capture_output=True, text=True)
    return result.stdout.strip() if result.stdout else ""

with open("CHANGELOG.md", "r", encoding="utf-8") as f:
    content = f.read()

def extract_changelog(version=None):
    if version:
        if version.startswith('Nv') or re.match(r'^\d+\.\d+', version):
            pattern = rf"## {re.escape(version.lstrip('Nv'))}(.*?)(?=## |$)"
            match = re.search(pattern, content, re.DOTALL)
            
            if match:
                return match.group(1).strip(), version
            else:
                return None, version
        else:
            return content, None
    else:
        pattern = r"## (.*?)(?=## |$)"
        match = re.search(pattern, content, re.DOTALL)
        
        if match:
            full_content = match.group(0).strip()
            parts = full_content.split('\n', 1)
            if len(parts) > 1:
                return parts[1].strip(), None
            else:
                return full_content, None
        else:
            return None, None

changelog, version = extract_changelog(sys.argv[1] if len(sys.argv) > 1 else None)

if changelog is not None:
    print(changelog)
    
    try:
        if version:
            version_with_prefix = version if version.startswith('Nv') else f'Nv{version}'
            last_tag = run_git_command(["git", "describe", "--abbrev=0", "--tags", f"{version_with_prefix}^"])
            if not last_tag:
                last_tag = run_git_command(["git", "describe", "--abbrev=0", "--tags"])
        else:
            last_tag = run_git_command(["git", "describe", "--abbrev=0", "--tags"])
    except:
        last_tag = run_git_command(["git", "describe", "--abbrev=0", "--tags"])
    
    if not last_tag:
        last_tag = "Nv1.0.0"
    
    if version:
        to_tag = version if version.startswith('Nv') else f'Nv{version}'
    else:
        to_tag = "simple-native"
    
    print(f"\n修改记录：[{last_tag} -> {to_tag}](https://github.com/SageMik/sqlite3_simple/compare/{last_tag}...{to_tag})")
else:
    if version:
        print(f"未找到版本 {version} 的 CHANGELOG")
    else:
        print("未找到 CHANGELOG 内容")