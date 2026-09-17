import os

gradle_path = 'android/app/build.gradle'
kts_path = 'android/app/build.gradle.kts'
target = kts_path if os.path.exists(kts_path) else gradle_path

with open(target, 'r') as f:
    content = f.read()

if target == kts_path:
    sign_block = """
    signingConfigs {
        create("release") {
            storeFile = file("mindmod.jks")
            storePassword = "mindmod"
            keyAlias = "mindmod"
            keyPassword = "mindmod"
        }
    }
"""
    content = content.replace('buildTypes {', sign_block + '    buildTypes {')
    content = content.replace('signingConfig = signingConfigs.getByName("debug")', 'signingConfig = signingConfigs.getByName("release")')
else:
    sign_block = """
    signingConfigs {
        release {
            storeFile file("mindmod.jks")
            storePassword "mindmod"
            keyAlias "mindmod"
            keyPassword "mindmod"
        }
    }
"""
    content = content.replace('buildTypes {', sign_block + '    buildTypes {')
    content = content.replace('signingConfig signingConfigs.debug', 'signingConfig signingConfigs.release')

with open(target, 'w') as f:
    f.write(content)

print("Keystore successfully configured in", target)
