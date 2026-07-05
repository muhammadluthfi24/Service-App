# Service App - Aplikasi Layanan Jasa Berbasis Mobile

Service App adalah aplikasi mobile berbasis Flutter yang memudahkan pengguna untuk menemukan dan memesan berbagai layanan jasa profesional seperti kebersihan, perbaikan, listrik, plumbing, dan lainnya.

## 🎯 Fitur Utama

- **Autentikasi Pengguna**: Login dan registrasi dengan validasi
- **Kategori Layanan**: 8 kategori layanan yang berbeda
- **Pencarian Layanan**: Cari layanan sesuai kebutuhan
- **Detail Layanan**: Informasi lengkap tentang setiap layanan
- **Booking System**: Sistem pemesanan dengan form lengkap
- **Manajemen Pesanan**: Lihat status pesanan (Aktif, Selesai, Dibatalkan)
- **Profil Pengguna**: Kelola informasi profil dan preferensi
- **UI/UX Modern**: Desain yang bersih dan mudah digunakan dengan warna orange (#FF8F28)

## 🛠️ Teknologi yang Digunakan

- **Framework**: Flutter 3.9.2
- **Bahasa**: Dart
- **State Management**: StatefulWidget
- **UI Components**: Material Design 3
- **Font**: Google Fonts (Poppins)
- **Packages**:
  - `google_fonts`: ^6.1.0
  - `flutter_svg`: ^2.0.9
  - `shared_preferences`: ^2.2.2
  - `intl`: ^0.19.0

## 📁 Struktur Proyek

```
lib/
├── main.dart                 # Entry point aplikasi
├── models/                   # Data models
│   └── service_model.dart
├── screens/                  # Semua layar aplikasi
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── main_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── service/
│   │   ├── service_list_screen.dart
│   │   └── service_detail_screen.dart
│   ├── booking/
│   │   ├── booking_screen.dart
│   │   ├── booking_form_screen.dart
│   │   └── booking_success_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── widgets/                  # Reusable widgets
│   ├── category_card.dart
│   └── service_card.dart
├── data/                     # Dummy data
│   └── dummy_data.dart
└── utils/                    # Utilities & constants
    └── constants.dart
```

## 🚀 Cara Menjalankan Aplikasi

### Prerequisites
- Flutter SDK (3.9.2 atau lebih baru)
- Android Studio / VS Code
- Android Emulator / iOS Simulator / Physical Device

### Langkah-langkah

1. Clone repository
```bash
git clone <repository-url>
cd Capstone2
```

2. Install dependencies
```bash
flutter pub get
```

3. Jalankan aplikasi
```bash
flutter run
```

4. Build APK (untuk Android)
```bash
flutter build apk --release
```

## 📱 Alur Aplikasi

1. **Splash Screen** → Tampilan awal aplikasi
2. **Onboarding** → Pengenalan fitur aplikasi (3 halaman)
3. **Login/Register** → Autentikasi pengguna
4. **Home** → Halaman utama dengan kategori dan layanan populer
5. **Service List** → Daftar layanan berdasarkan kategori
6. **Service Detail** → Detail lengkap layanan
7. **Booking Form** → Form pemesanan layanan
8. **Booking Success** → Konfirmasi pemesanan berhasil
9. **My Bookings** → Daftar pesanan pengguna
10. **Profile** → Profil dan pengaturan pengguna

## 🎨 Design System

### Warna
- **Primary**: #FF8F28 (Orange)
- **Secondary**: #2C3E50 (Dark Blue)
- **Background**: #F5F5F5 (Light Grey)
- **Success**: #4CAF50 (Green)
- **Error**: #F44336 (Red)

### Typography
- **Font Family**: Poppins
- **Heading 1**: 28px, Bold
- **Heading 2**: 22px, Bold
- **Heading 3**: 18px, SemiBold
- **Body Large**: 16px
- **Body Medium**: 14px
- **Body Small**: 12px

## 📊 Kategori Layanan

1. Kebersihan (Cleaning Services)
2. Perbaikan (Repair Services)
3. Listrik (Electrical Services)
4. Plumbing
5. AC & Elektronik
6. Pengecatan (Painting)
7. Taman (Gardening)
8. Lainnya (Others)

## 👨‍💻 Developer

Muhammad Luthfi Farizqi Dengan nim 235410060
Proyek CAPSTONE 2 - Service App
Universitas/Institusi: Universitas Teknologi Digital Indonesia
Tahun: 2026

## 📄 Lisensi

Proyek ini dibuat untuk keperluan dan pembelajaran.
