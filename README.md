# 🎯 SpinDecide – Decision Maker App

Aplikasi web multiplatform untuk mengambil keputusan dengan spin wheel interaktif.

---

## 📁 Struktur Folder

```
spinwheel/
├── login.html          ← Halaman login
├── register.html       ← Halaman registrasi
├── dashboard.html      ← Halaman utama (spin wheel)
├── history.html        ← Riwayat spin
├── style.css           ← Semua styling (responsive)
├── supabase.js         ← Konfigurasi Supabase ← EDIT INI!
├── auth.js             ← Fungsi login/register/logout
├── spin.js             ← Logika roda & animasi
├── history.js          ← Logika riwayat & statistik
├── manifest.json       ← Konfigurasi PWA
├── sw.js               ← Service Worker (offline)
└── icons/
    ├── icon-192.png    ← Ikon PWA kecil
    └── icon-512.png    ← Ikon PWA besar
```

---

## 🔧 LANGKAH SETUP (WAJIB DIBACA!)

### 1. Buat Akun Supabase

1. Buka https://supabase.com
2. Klik "Start your project" → Daftar dengan GitHub
3. Klik "New Project"
4. Isi:
   - Name: `spinwheel-app`
   - Password: buat password kuat
   - Region: Southeast Asia (Singapore)
5. Tunggu ~2 menit

### 2. Buat Tabel Database

Buka **SQL Editor** di Supabase, jalankan:

```sql
CREATE TABLE spins (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  options TEXT[] NOT NULL,
  result TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE spins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own spins" ON spins
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own spins" ON spins
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### 3. Isi Kredensial di supabase.js

Buka **Settings → API** di Supabase, lalu edit file `supabase.js`:

```javascript
const SUPABASE_URL = 'https://XXXXX.supabase.co';    // ← ganti
const SUPABASE_ANON_KEY = 'eyJhbGci...';              // ← ganti
```

### 4. (Opsional) Matikan Verifikasi Email

Agar bisa langsung login tanpa verifikasi email:
- Buka **Authentication → Providers → Email**
- Matikan "Confirm email"

### 5. Jalankan Aplikasi

Buka `login.html` di browser, atau host di:
- **Netlify** (drag & drop folder → gratis)
- **Vercel** (gratis)
- **GitHub Pages** (gratis)

---

## 📱 Install sebagai PWA (di HP)

### Android (Chrome):
1. Buka URL aplikasi di Chrome
2. Tap ikon tiga titik (⋮)
3. Pilih "Tambahkan ke layar utama"
4. Tap "Tambah"

### iOS (Safari):
1. Buka URL di Safari
2. Tap ikon Share (□↑)
3. Pilih "Add to Home Screen"
4. Tap "Add"

---

## 🔌 Persiapan Flutter (Android)

Flutter nanti akan pakai **Supabase yang sama** dengan cara:

```dart
// pubspec.yaml
dependencies:
  supabase_flutter: ^2.0.0
  flutter_local_notifications: ^17.0.0
```

```dart
// main.dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://XXXXX.supabase.co',      // ← URL sama dengan web
    anonKey: 'eyJhbGci...',                 // ← Key sama dengan web
  );
  
  runApp(MyApp());
}
```

```dart
// Simpan spin result (sama dengan web)
final supabase = Supabase.instance.client;

await supabase.from('spins').insert({
  'user_id': supabase.auth.currentUser!.id,
  'options': ['Pilihan A', 'Pilihan B'],
  'result': 'Pilihan A',
});
```

```dart
// Notifikasi lokal Flutter
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

Future<void> showSpinNotification(String result) async {
  await notifications.show(
    0,
    '🎯 Hasil Spin!',
    'Kamu mendapat: $result',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'spin_channel', 'Spin Results',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
  );
}
```

---

## ✅ Checklist Pengujian

- [ ] Register berhasil
- [ ] Login berhasil
- [ ] Tambah pilihan ke roda
- [ ] Animasi spin berjalan
- [ ] Hasil tersimpan ke Supabase
- [ ] Riwayat tampil di halaman history
- [ ] Data bisa diakses dari device lain (login akun sama)
- [ ] Tampilan responsif di desktop (horizontal)
- [ ] Tampilan responsif di HP (vertikal)
- [ ] PWA bisa diinstall di HP

---

## 🎨 Teknologi

| Komponen    | Teknologi              | Biaya |
|-------------|------------------------|-------|
| Frontend    | HTML + CSS + JS Vanilla| Gratis |
| Backend     | Supabase               | Gratis |
| Auth        | Supabase Auth          | Gratis |
| Database    | Supabase PostgreSQL    | Gratis |
| PWA         | Service Worker         | Gratis |
| Hosting     | Netlify/Vercel         | Gratis |
| Mobile      | Flutter (selanjutnya)  | Gratis |
