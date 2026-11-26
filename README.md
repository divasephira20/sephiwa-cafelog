# ☕ Sephiwa’s Cafe Log

**Sephiwa’s Cafe Log** adalah aplikasi mobile berbasis **Flutter** yang berfungsi sebagai katalog kuliner visual, pencari lokasi, sekaligus jurnal ulasan pribadi (*personal coffee & culinary hopping journal*) untuk mencatat rekomendasi *coffee shop*, restoran, dan *bakery* di **Bandung** maupun saat **perjalanan kerja luar kota** (*Work Trip*).

Aplikasi ini dirancang dengan estetika *Light Editorial & Airy* (perpaduan latar Alabaster White `#FCFBF9` dan aksen gradasi Champagne Cream `#F7E7CE` ke Blush Silk `#F3D9DC`) serta terintegrasi langsung dengan **REST API (MockAPI.io)** untuk operasi CRUD secara *real-time*.

---

## ✨ Fitur Utama

- **Visual Culinary & Cafe Catalog:** Menampilkan kartu rekomendasi *Coffee Shop*, *Resto*, dan *Bakery* lengkap dengan foto, rating bintang, status (*Visited* / *Wishlist*), serta pil lokasi kota.
- **Smart Search & Multi-Filter:** Pencarian cepat berdasarkan nama tempat, kota, atau menu favorit, dilengkapi filter kategori (`All`, `Bandung`, `Work Trip`, `Visited`, `Wishlist`).
- **Today's Coffee Pick (Randomizer):** Fitur acak spot untuk membantu memilih tempat ngopi berikutnya secara instan.
- **Must-Order & Vibe Tags Highlight:** Menyoroti menu wajib pesan (*Signature Order*), estimasi harga, jam buka, jarak *landmark*, serta tag suasana seperti `Early Bird`, `Creamy Iced Coffee`, `WFC Friendly`, dan `Afterwork Chill`.
- **Location & Maps Integration:** Detail alamat lengkap tiap tempat beserta integrasi tautan Google Maps.
- **Cloud CRUD via MockAPI.io:** Mendukung operasi **Create** (tambah spot baru), **Read** (lihat daftar & detail), **Update** (edit ulasan, rating, atau pindah status *Wishlist* ke *Visited*), dan **Delete** (hapus spot) menggunakan HTTP REST API.

---

## 🛠️ Teknologi & Arsitektur

- **Framework:** Flutter (Dart)
- **Backend / Cloud Storage:** MockAPI.io (`http` package untuk GET, POST, PUT, DELETE)
- **Design & Prototyping:** Google Stitch
- **Arsitektur Proyek:**
  ```text
  lib/
  ├── models/
  │   └── cafe_spot.dart          # Model data CafeSpot & serialisasi JSON (20 fields)
  ├── services/
  │   └── api_service.dart        # Layanan HTTP REST API (GET, POST, PUT, DELETE)
  ├── screens/
  │   ├── home_screen.dart        # Discovery & Journal Feed + Hero Banner & Filter
  │   ├── spot_detail_screen.dart # Detail lokasi, Must Order, & catatan ulasan
  │   ├── spot_form_screen.dart   # Form tambah & edit data spot (CRUD)
  │   └── wishlist_screen.dart    # Ringkasan perjalanan & manajemen Visited/Wishlist
  ├── theme/
  │   └── app_theme.dart          # Palet warna Light Editorial & tipografi
  └── main.dart                   # Entry point & navigasi utama
