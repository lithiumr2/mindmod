import os
import re

# 1. Patch android/app/build.gradle(.kts)
gradle_path = 'android/app/build.gradle'
kts_path = 'android/app/build.gradle.kts'
target = kts_path if os.path.exists(kts_path) else gradle_path

if os.path.exists(target):
    with open(target, 'r') as f:
        content = f.read()
    content = re.sub(r'compileSdk\s*=.*', 'compileSdk = 36', content)
    content = re.sub(r'targetSdk\s*=.*', 'targetSdk = 34', content)
    content = re.sub(r'minSdk\s*=.*', 'minSdk = 21', content)
    
    # Disable AarMetadata check
    if 'tasks.configureEach' not in content:
        if target.endswith('.kts'):
            content += """
tasks.configureEach {
    if (name.contains("AarMetadata", ignoreCase = true)) {
        enabled = false
    }
}
"""
        else:
            content += """
tasks.configureEach { task ->
    if (task.name.contains("AarMetadata")) {
        task.enabled = false
    }
}
"""
    with open(target, 'w') as f:
        f.write(content)
    print("Patched app target:", target)

# 2. Update properties
for prop_file in ['android/local.properties', 'android/gradle.properties']:
    if os.path.exists(prop_file):
        with open(prop_file, 'a') as f:
            f.write('\nflutter.compileSdkVersion=36\nflutter.minSdkVersion=21\nflutter.targetSdkVersion=34\n')
        print("Updated property file:", prop_file)

# 3. Patch ~/.pub-cache plugins directly
pub_cache_dirs = [os.path.expanduser('~/.pub-cache'), os.path.expanduser('~/.pub-cache/hosted/pub.dev')]
for pub_dir in pub_cache_dirs:
    if os.path.exists(pub_dir):
        for root, dirs, files in os.walk(pub_dir):
            for f in files:
                if f in ['build.gradle', 'build.gradle.kts']:
                    filepath = os.path.join(root, f)
                    try:
                        with open(filepath, 'r', encoding='utf-8', errors='ignore') as gf:
                            c = gf.read()
                        new_c = re.sub(r'compileSdkVersion\s+([0-9]+)', 'compileSdkVersion 36', c)
                        new_c = re.sub(r'compileSdk\s*=\s*([0-9]+)', 'compileSdk = 36', new_c)
                        if new_c != c:
                            with open(filepath, 'w', encoding='utf-8') as gf:
                                gf.write(new_c)
                            print(f"Patched plugin in {filepath}")
                    except Exception as e:
                        pass
