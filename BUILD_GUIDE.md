# Panduan Build & Deploy Service App

## 📱 Build APK untuk Android

### 1. Build APK Debug (untuk testing)
```bash
flutter build apk --debug
```
File APK akan tersimpan di: `build/app/outputs/flutter-apk/app-debug.apk`

### 2. Build APK Release (untuk production)
```bash
flutter build apk --release
```
File APK akan tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

### 3. Build APK Split per ABI (ukuran lebih kecil)
```bash
flutter build apk --split-per-abi
```
Akan menghasilkan 3 file APK:
- `app-armeabi-v7a-release.apk` (untuk device 32-bit)
- `app-arm64-v8a-release.apk` (untuk device 64-bit)
- `app-x86_64-release.apk` (untuk emulator)

### 4. Build App Bundle (untuk Google Play Store)
```bash
flutter build appbundle --release
```
File AAB akan tersimpan di: `build/app/outputs/bundle/release/app-release.aab`

---

## 🍎 Build untuk iOS

### 1. Build iOS (memerlukan Mac)
```bash
flutter build ios --release
```

### 2. Build IPA untuk distribusi
```bash
flutter build ipa
```

---

## 🔧 Persiapan Sebelum Build Release

### 1. Update App Name
Edit file `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Service App"
    ...>
```

### 2. Update App Icon
Gunakan tool seperti [App Icon Generator](https://appicon.co/) atau jalankan:
```bash
flutter pub run flutter_launcher_icons:main
```

### 3. Update Package Name (opsional)
Edit file `android/app/build.gradle.kts`:
```kotlin
namespace = "com.example.serviceapp"
```

### 4. Generate Signing Key (untuk release)
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 5. Konfigurasi Signing
Buat file `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

Edit `android/app/build.gradle.kts` untuk menambahkan signing config.

---

## 📊 Ukuran APK

Estimasi ukuran APK:
- Debug: ~50-60 MB
- Release: ~20-25 MB
- Release (split-per-abi): ~15-18 MB per file

---

## 🧪 Testing APK

### 1. Install APK ke Device
```bash
flutter install
```

### 2. Install APK Manual
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 3. Testing di Emulator
```bash
flutter run --release
```

---

## 📦 Distribusi

### Google Play Store
1. Build App Bundle: `flutter build appbundle --release`
2. Upload ke Google Play Console
3. Isi informasi aplikasi (deskripsi, screenshot, dll)
4. Submit untuk review

### Direct Distribution (APK)
1. Build APK Release
2. Upload ke website/cloud storage
3. Share link download
4. User harus enable "Install from Unknown Sources"

---

## ✅ Checklist Sebelum Release

- [ ] Test semua fitur aplikasi
- [ ] Update version number di `pubspec.yaml`
- [ ] Update app name dan icon
- [ ] Generate signing key
- [ ] Build release APK/AAB
- [ ] Test APK di berbagai device
- [ ] Siapkan screenshot untuk store listing
- [ ] Tulis deskripsi aplikasi
- [ ] Siapkan privacy policy (jika diperlukan)

---

## 🐛 Troubleshooting

### Error: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### Error: "SDK version"
Update `android/app/build.gradle.kts`:
```kotlin
minSdk = 21
targetSdk = 34
```

### Error: "Signing key not found"
Pastikan file `key.properties` sudah dibuat dan path keystore benar.

---

## 📝 Version Management

Update version di `pubspec.yaml`:
```yaml
version: 1.0.0+1
```
Format: `major.minor.patch+buildNumber`

Contoh:
- `1.0.0+1` - Initial release
- `1.0.1+2` - Bug fix
- `1.1.0+3` - New features
- `2.0.0+4` - Major update

---

## 🚀 Continuous Integration (CI/CD)

Untuk automation, bisa menggunakan:
- GitHub Actions
- GitLab CI/CD
- Codemagic
- Bitrise

Contoh GitHub Actions workflow akan ditambahkan di file `.github/workflows/build.yml`
