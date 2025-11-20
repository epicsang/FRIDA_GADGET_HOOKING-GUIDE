# BioShield Hook Templates

This folder contains **ready-to-use** template files for manual Frida Gadget hooking.

## 📁 Files Included

### 1. `libfrida-gadget.config.so`
**Purpose:** Tells Frida Gadget to load your hook script
**Usage:** Copy as-is to `lib/<architecture>/` folder
**DO NOT EDIT** unless you know what you're doing

### 2. `libfrida-gadget.script.so`
**Purpose:** JavaScript hook code that monitors biometric authentication
**Usage:** Copy as-is to `lib/<architecture>/` folder
**What it does:**
- Hooks `androidx.biometric.BiometricPrompt` (modern API)
- Hooks `FingerprintManager` (legacy API)
- Logs all events in **encrypted format** (AES-256-GCM)
- Detects crypto binding usage
- Writes logs to `/storage/emulated/0/Download/BioShield/logs.jsonl`

**DO NOT EDIT** - this is production code

### 3. `smali_injection.txt`
**Purpose:** Shows you EXACTLY what to add to MainActivity.smali
**Usage:**
1. Open your decompiled app's `MainActivity.smali`
2. Find the `onCreate()` method
3. Copy the code from this file
4. Paste it AFTER `invoke-super` line

### 4. `AndroidManifest_patch.xml`
**Purpose:** Shows what to add to AndroidManifest.xml
**Usage:** Add `android:extractNativeLibs="true"` to `<application>` tag

---

## 🚀 Quick Start Guide

### Step 1: Download Frida Gadget Binary

```bash
# For Android Emulator (x86_64)
wget https://github.com/frida/frida/releases/download/16.5.9/frida-gadget-16.5.9-android-x86_64.so.xz
xz -d frida-gadget-16.5.9-android-x86_64.so.xz
mv frida-gadget-16.5.9-android-x86_64.so libfrida-gadget.so

# For Physical Device (arm64)
wget https://github.com/frida/frida/releases/download/16.5.9/frida-gadget-16.5.9-android-arm64.so.xz
xz -d frida-gadget-16.5.9-android-arm64.so.xz
mv frida-gadget-16.5.9-android-arm64.so libfrida-gadget.so
```

### Step 2: Decompile Your APK

```bash
apktool d your-app.apk -o app_decompiled
```

### Step 3: Inject Loader into MainActivity.smali

1. Open `app_decompiled/smali*/com/yourapp/MainActivity.smali`
2. Find `.method protected onCreate(Landroid/os/Bundle;)V`
3. Add the code from `smali_injection.txt` AFTER `invoke-super` line

### Step 4: Patch AndroidManifest.xml

Open `app_decompiled/AndroidManifest.xml` and add:

```xml
<application
    android:extractNativeLibs="true"
    ...>
```

### Step 5: Copy Hook Files

```bash
# For x86_64 (emulator)
mkdir -p app_decompiled/lib/x86_64
cp libfrida-gadget.so app_decompiled/lib/x86_64/
cp libfrida-gadget.config.so app_decompiled/lib/x86_64/
cp libfrida-gadget.script.so app_decompiled/lib/x86_64/

# For arm64 (physical device)
mkdir -p app_decompiled/lib/arm64-v8a
cp libfrida-gadget.so app_decompiled/lib/arm64-v8a/
cp libfrida-gadget.config.so app_decompiled/lib/arm64-v8a/
cp libfrida-gadget.script.so app_decompiled/lib/arm64-v8a/
```

⚠️ **CRITICAL:** All three files MUST be in the SAME architecture folder!

### Step 6: Rebuild and Sign

```bash
# Rebuild
apktool b app_decompiled -o app_repacked.apk

# Align
zipalign -f -v 4 app_repacked.apk app_aligned.apk

# Sign (using debug keystore)
apksigner sign \
    --ks ~/.android/debug.keystore \
    --ks-pass pass:android \
    --key-pass pass:android \
    --min-sdk-version 21 \
    --out app_final.apk \
    app_aligned.apk

# Verify
apksigner verify app_final.apk
```

### Step 7: Install and Test

```bash
# Install
adb install -r app_final.apk

# Monitor logs
adb logcat | grep -E "BioShield|FRIDA"
```

### Expected Output

When app launches:
```
I FRIDA   : Frida Gadget loaded
I BioShield: [BioShield] Loading hook script...
I BioShield: [BioShield] Java.perform() started
I BioShield: [BioShield] Found androidx.biometric.BiometricPrompt
I BioShield: [BioShield] ✓ BiometricPrompt hooks active
I BioShield: [BioShield] ✓ All hooks initialized successfully
```

When biometric authentication happens:
```
I BioShield: [HOOK] BiometricPrompt.authenticate() called (no crypto)
I BioShield: [LOG] Encrypted event written to: /storage/emulated/0/Download/BioShield/logs.jsonl
I BioShield: [EVENT] ✓ Authentication SUCCEEDED
```

---

## 📊 What Gets Logged

The hook automatically logs:

- **Event Type:** `auth_started`, `success`, `failed`, `error`
- **Timestamp:** Milliseconds since epoch
- **Crypto Binding:** Whether `CryptoObject` was used
- **Method:** `BiometricPrompt` or `FingerprintManager`
- **Error Details:** Error codes and messages (if applicable)

All logs are **encrypted with AES-256-GCM** before writing to disk.

---

## 🔒 Security Notes

1. **Encryption Key:** Hardcoded in the script (for demo purposes)
   - Production apps should use Android Keystore
   - Key rotation recommended

2. **Log File Location:** `/storage/emulated/0/Download/BioShield/`
   - Accessible to BioShield app with `MANAGE_EXTERNAL_STORAGE` permission
   - Not accessible to other apps without root

3. **Hook Detection:** This method can be detected by:
   - Frida detection libraries
   - Root detection
   - APK signature verification

   **Use only for security testing and research!**

---

## ❓ Troubleshooting

### App crashes with "UnsatisfiedLinkError"
- ✓ Check `android:extractNativeLibs="true"` in manifest
- ✓ Verify all 3 `.so` files are in correct architecture folder
- ✓ Make sure files end with `.so` extension

### Gadget loads but no hooks execute
- ✓ Check logcat for JavaScript errors
- ✓ Verify `libfrida-gadget.config.so` has valid JSON
- ✓ Make sure app actually uses BiometricPrompt API

### Logs not created
- ✓ Check app has storage permissions
- ✓ Verify `/storage/emulated/0/Download` is accessible
- ✓ Look for encryption errors in logcat

---

## 📚 Additional Resources

- [Frida Documentation](https://frida.re/docs/)
- [Frida Gadget Configuration](https://frida.re/docs/gadget/)
- [APKTool Documentation](https://apktool.org/)
- [BioShield Main Documentation](../README.md)

---

**Version:** 1.0
**Last Updated:** 2025-01-20
**License:** For educational and security research purposes only
