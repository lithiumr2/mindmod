import os
import re

gradle_path = 'android/app/build.gradle'
kts_path = 'android/app/build.gradle.kts'
target = kts_path if os.path.exists(kts_path) else gradle_path

if os.path.exists(target):
    with open(target, 'r') as f:
        content = f.read()
    content = re.sub(r'compileSdk\s*=.*', 'compileSdk = 34', content)
    content = re.sub(r'targetSdk\s*=.*', 'targetSdk = 34', content)
    content = re.sub(r'minSdk\s*=.*', 'minSdk = 21', content)
    with open(target, 'w') as f:
        f.write(content)
    print("Patched target:", target)

for prop_file in ['android/local.properties', 'android/gradle.properties']:
    with open(prop_file, 'a') as f:
        f.write('\nflutter.compileSdkVersion=34\nflutter.minSdkVersion=21\nflutter.targetSdkVersion=34\n')
    print("Updated property file:", prop_file)
