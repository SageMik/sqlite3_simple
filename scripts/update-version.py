import re

version = "2.1.0"
files = [
    ("src/android/simple-native-android/build.gradle.kts", r'(?m)^version = "[\d\.\+]+"', f'version = "{version}"'),
    ("src/android/README.md", r'simple-native-android:[\d\.\+]+', f'simple-native-android:{version}'),
    ("src/ohos/simple_native_ohos/oh-package.json5", r'"version": "[\d\.\+]+"', f'"version": "{version}"')
]

for path, pattern, replacement in files:
    content = open(path, encoding='utf-8').read()
    open(path, 'w', encoding='utf-8').write(re.sub(pattern, replacement, content))
