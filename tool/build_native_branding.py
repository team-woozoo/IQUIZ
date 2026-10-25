"""Android/iOS 시작 화면을 로고 없는 흰색 배경으로 구성합니다.

Flutter가 준비되면 SplashPage의 Lottie 애니메이션으로 이어집니다.
런처 아이콘은 flutter_launcher_icons로 별도 생성합니다.
"""
from pathlib import Path
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]

# iOS의 기본/dev/prod 시작 화면에서 정지 로고와 관련 제약을 제거
for relative in ['ios/Runner/devLaunchScreen.storyboard', 'ios/Runner/prodLaunchScreen.storyboard', 'ios/Runner/Base.lproj/LaunchScreen.storyboard']:
    path = ROOT / relative
    tree = ET.parse(path)
    root = tree.getroot()
    view = root.find('.//view[@key="view"]')
    for child in list(view):
        if child.tag in {'subviews', 'constraints'}:
            view.remove(child)
    color = view.find('./color[@key="backgroundColor"]')
    color.attrib.clear()
    color.attrib.update(key='backgroundColor', white='1', alpha='1', colorSpace='custom', customColorSpace='genericGamma22GrayColorSpace')
    resources = root.find('./resources')
    if resources is not None:
        root.remove(resources)
    ET.indent(tree, space='    ')
    tree.write(path, encoding='utf-8', xml_declaration=True)

project = ROOT / 'ios/Runner.xcodeproj/project.pbxproj'
project.write_text(re.sub(r'(?ms)[A-F0-9]{24} /\* (?:Debug|Release|Profile)-(dev|prod) \*/ = \{.*?\n\t\t\};',
    lambda m: m.group(0).replace('ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;', f'ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-{m.group(1)};'),
    project.read_text()))

launch_xml = '''<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
</layer-list>
'''
for directory in ['drawable', 'drawable-v21']:
    (ROOT / f'android/app/src/main/res/{directory}/launch_background.xml').write_text(launch_xml)

# Android 12+는 아이콘을 생략하면 런처 아이콘을 사용하므로 투명 리소스를 명시
(ROOT / 'android/app/src/main/res/drawable/launch_icon_transparent.xml').write_text('''<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="288dp"
    android:height="288dp"
    android:viewportWidth="288"
    android:viewportHeight="288">
    <path android:fillColor="#00000000" android:pathData="M0,0h288v288h-288z" />
</vector>
''')

styles = '''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@drawable/launch_background</item>
        <item name="android:windowLightStatusBar">true</item>
        <item name="android:navigationBarColor">#FFFFFF</item>
{android12}    </style>
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@android:color/white</item>
    </style>
</resources>
'''
android12 = '''        <item name="android:windowSplashScreenBackground">#FFFFFF</item>
        <item name="android:windowSplashScreenAnimatedIcon">@drawable/launch_icon_transparent</item>
        <item name="android:windowSplashScreenIconBackgroundColor">@android:color/transparent</item>
'''
for directory in ['values', 'values-night', 'values-v31', 'values-night-v31']:
    dest = ROOT / f'android/app/src/main/res/{directory}'
    dest.mkdir(parents=True, exist_ok=True)
    (dest / 'styles.xml').write_text(styles.format(android12=android12 if 'v31' in directory else ''))

print('Android·iOS의 로고 없는 흰색 시작 화면 생성 완료')
