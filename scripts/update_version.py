import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

version = "2.2.0"
files = [
    (ROOT / "src/android/simple-native-android/build.gradle.kts", r'(?m)^version = "[\d\.\+]+"', f'version = "{version}"'),
    (ROOT / "src/android/README.md", r'simple-native-android:[\d\.\+]+', f'simple-native-android:{version}'),
    (ROOT / "src/ohos/simple_native_ohos/oh-package.json5", r'"version": "[\d\.\+]+"', f'"version": "{version}"'),
    (ROOT / "src/ohos/simple_native_ohos/BuildProfile.ets", r"export const HAR_VERSION = '[\d\.\+]+'", f"export const HAR_VERSION = '{version}'"),
]

for path, pattern, replacement in files:
    content = path.read_text(encoding='utf-8')
    path.write_text(re.sub(pattern, replacement, content), encoding='utf-8')
