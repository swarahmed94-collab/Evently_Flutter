#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v flutter >/dev/null || { echo 'Flutter SDK is required'; exit 1; }
command -v xcodebuild >/dev/null || { echo 'Xcode is required to run iOS Simulator'; exit 1; }
flutter create --project-name evently --platforms=ios,android .
flutter pub get
PLIST="ios/Runner/GoogleService-Info.plist"
if [ ! -f "$PLIST" ]; then
  echo 'Add your Firebase iOS GoogleService-Info.plist to ios/Runner/ before launching.'
  exit 2
fi
# Configure bundle ID, URL callback, and minimum Firebase iOS deployment target.
python3 - <<'PY'
import plistlib,pathlib,re
source=pathlib.Path('ios/Runner/GoogleService-Info.plist')
with source.open('rb') as f: config=plistlib.load(f)
bundle=config.get('BUNDLE_ID')
reversed_id=config.get('REVERSED_CLIENT_ID')
project=pathlib.Path('ios/Runner.xcodeproj/project.pbxproj')
data=project.read_text()
if bundle:
    data=re.sub(r'(PRODUCT_BUNDLE_IDENTIFIER\s*=\s*)[^;]+;',lambda m:m.group(1)+bundle+';',data)
# Firebase Apple SDK 12 and newer requires iOS 15 or later.
data=re.sub(r'(IPHONEOS_DEPLOYMENT_TARGET\s*=\s*)[^;]+;',r'\g<1>15.0;',data)
project.write_text(data)
podfile=pathlib.Path('ios/Podfile')
if podfile.exists():
    body=podfile.read_text()
    body=re.sub(r"platform :ios, '[^']+'", "platform :ios, '15.0'", body)
    if 'platform :ios' not in body: body="platform :ios, '15.0'\n"+body
    podfile.write_text(body)
info=pathlib.Path('ios/Runner/Info.plist')
with info.open('rb') as f: plist=plistlib.load(f)
if reversed_id:
    types=plist.setdefault('CFBundleURLTypes',[])
    if not any(reversed_id in group.get('CFBundleURLSchemes',[]) for group in types):
        types.append({'CFBundleTypeRole':'Editor','CFBundleURLSchemes':[reversed_id]})
with info.open('wb') as f: plistlib.dump(plist,f)
print('Firebase bundle configured:',bundle or 'missing bundle ID')
PY
cd ios
pod install
cd ..
flutter run -d ios
