@echo off
echo =====================================
echo   Doctors App - Android APK
echo =====================================
echo.
echo APK File Location:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo To install on your Android phone:
echo.
echo Option 1: USB Transfer
echo ---------------------
echo 1. Connect your phone to PC via USB
echo 2. Copy the APK file to your phone
echo 3. On your phone, open the APK file
echo 4. Allow installation from unknown sources if prompted
echo 5. Tap Install
echo.
echo Option 2: Share via Email/Cloud
echo --------------------------------
echo 1. Send the APK to yourself via email or Google Drive
echo 2. Download it on your phone
echo 3. Open and install the APK
echo.
echo Option 3: Install via ADB (Developer Mode)
echo -------------------------------------------
echo 1. Enable USB Debugging on your phone
echo 2. Connect via USB
echo 3. Run: adb install build\app\outputs\flutter-apk\app-release.apk
echo.
pause
