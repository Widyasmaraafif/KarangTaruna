# Karang Taruna – Cahya Muda App

Aplikasi manajemen kegiatan dan keuangan Karang Taruna berbasis Flutter, Supabase, dan Firebase.  
Aplikasi ini membantu pengurus dan anggota untuk mengelola kegiatan, informasi, aspirasi warga, polling, serta keuangan pribadi maupun organisasi secara terpusat.

## Tech Stack

- Flutter (Dart SDK ^3.10.4)
- GetX (state management & routing)
- Supabase (auth, database, storage)
- Firebase Core & Firebase Messaging (push notification)
- GetStorage (local storage)
- flutter_dotenv (environment variables)
- image_picker, intl, dan paket pendukung lain

## Fitur Utama

- Autentikasi & Profil
  - Login dan registrasi menggunakan email dan password
  - Manajemen profil anggota (nama lengkap, avatar, nomor telepon)
  - Role-based access (Admin, Ketua, Wakil Ketua, Sekretaris, Bendahara, Pubdekdok, Anggota/User)

- Beranda & Informasi
  - Berita Karang Taruna (News) lengkap dengan gambar dan detail berita
  - Pengumuman penting (Announcements) dengan badge penanda
  - Banner informasi singkat di halaman utama

- Kegiatan & Event
  - Daftar kegiatan Karang Taruna (upcoming, ongoing, completed)
  - Detail kegiatan: judul, deskripsi, tanggal/waktu, lokasi

- Keuangan
  - Keuangan Pribadi: daftar tagihan (bills) yang harus dibayar anggota
  - Keuangan Organisasi: akun keuangan (finance_accounts) dan transaksi (finance_transactions)
  - Halaman detail akun untuk melihat riwayat transaksi

- Aspirasi / Pojok Kampung
  - Warga/anggota dapat mengirim aspirasi dengan judul, kategori, isi, dan foto
  - Status tindak lanjut aspirasi (mis. Menunggu Tindak Lanjut, Sedang Ditinjau)
  - Halaman “Aspirasi Saya” dan daftar semua aspirasi

- Polling
  - Membuat dan mengelola polling kegiatan
  - Opsi polling dinamis dengan perhitungan jumlah suara
  - Batasan satu suara per user per polling (dikelola di server dan aplikasi)

- Galeri
  - Grid foto kegiatan Karang Taruna
  - Halaman detail dengan tampilan full-screen dan zoom

- Dashboard Admin
  - Kelola berita, pengumuman, kegiatan/event
  - Kelola galeri foto
  - Kelola polling dan hasilnya
  - Kelola aspirasi/Pojok Kampung
  - Kelola keuangan organisasi (akun & transaksi)
  - Kelola anggota dan permintaan keanggotaan (membership requests)

- Notifikasi
  - Integrasi Firebase Cloud Messaging
  - Sinkronisasi FCM token ke profil user
  - Subscription topic khusus admin untuk notifikasi administratif

## Struktur Proyek Singkat

Struktur utama folder:

- `lib/main.dart` – entry point aplikasi, inisialisasi Supabase, Firebase, dotenv, dan GetStorage
- `lib/app.dart` – konfigurasi `GetMaterialApp` dan penentuan halaman awal (login / navigation menu)
- `lib/services/` – layanan seperti `SupabaseService` dan `NotificationService`
- `lib/controllers/` – controller global seperti `DataController`
- `lib/screens/` – kumpulan halaman (auth, home, event, news, announcement, finance, gallery, polling, aspiration, profile, admin dashboard, dll.)
- `lib/commons/widgets/` – komponen UI reusable (card, button, text field, dll.)

## Catatan Pengembangan

- Linting menggunakan paket `flutter_lints` yang telah dikonfigurasi di `analysis_options.yaml`.
- State management dan navigasi menggunakan GetX; pastikan mengikuti pola yang sudah ada di controller dan screens.

