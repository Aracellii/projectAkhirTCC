# Admin Dashboard - Panduan Penggunaan

## Deskripsi
Admin Dashboard adalah halaman khusus admin untuk mengelola lokasi donasi dan kategori produk dalam sistem Waste Management.

## Fitur Utama

### 1. Kelola Lokasi Donasi
Admin dapat menambahkan lokasi donasi (drop-point) baru dengan informasi:
- **Nama**: Nama lokasi donasi (wajib)
- **Alamat**: Alamat lengkap lokasi (wajib)
- **Kota**: Kota tempat lokasi berada (wajib)
- **Latitude**: Koordinat lintang (opsional)
- **Longitude**: Koordinat bujur (opsional)
- **Status Aktif**: Checkbox untuk menandai lokasi aktif

Fitur tambahan:
- ✓ Melihat daftar semua lokasi donasi
- ✓ Menghapus lokasi donasi
- ✓ Validasi form sebelum submit

### 2. Kelola Kategori Produk
Admin dapat menambahkan kategori produk baru dengan informasi:
- **Nama**: Nama kategori produk (wajib, contoh: Plastik, Kertas, Logam)
- **Kredit per kg**: Jumlah kredit yang diberikan per kg sampah dari kategori ini (opsional)

Fitur tambahan:
- ✓ Melihat daftar semua kategori produk
- ✓ Validasi form sebelum submit

## Cara Akses

### Dari Halaman Home
1. Buka website di `http://localhost:3000` (atau port yang dikonfigurasi)
2. Klik tombol "Admin Dashboard" untuk masuk ke dashboard

### URL Langsung
- Akses URL: `http://localhost:5173/admin`

## Teknologi yang Digunakan

### Backend
- **Express.js**: Framework Node.js
- **Sequelize**: ORM untuk database
- **JWT**: Authentication token
- **Port**: 5000

### Frontend
- **React**: UI library
- **React Router**: Navigation
- **Vite**: Build tool
- **Port**: 5173 (default Vite)

## API Endpoints

### Donation Locations
```
GET    /api/v1/donation-locations           # Ambil semua lokasi
POST   /api/v1/donation-locations           # Buat lokasi baru (auth required)
PUT    /api/v1/donation-locations/:id       # Update lokasi (auth required)
DELETE /api/v1/donation-locations/:id       # Hapus lokasi (auth required)
```

### Product Categories
```
GET    /api/v1/categories                  # Ambil semua kategori (auth required)
POST   /api/v1/categories                  # Buat kategori baru (auth required)
```

## Requirement Autentikasi

Untuk menambahkan/menghapus data, user harus login terlebih dahulu. Token akan disimpan di localStorage dengan key `token`.

### Contoh Request Header
```
Authorization: Bearer <token_dari_login>
Content-Type: application/json
```

## Validasi Form

### Lokasi Donasi
- Nama lokasi: Wajib diisi
- Alamat: Wajib diisi
- Kota: Wajib diisi
- Latitude/Longitude: Opsional, harus berupa angka desimal jika diisi

### Kategori Produk
- Nama kategori: Wajib diisi
- Kredit per kg: Opsional, harus berupa angka bulat jika diisi

## Struktur Database

### Tabel DonationLocations
```sql
CREATE TABLE DonationLocations (
  id         INT PRIMARY KEY AUTO_INCREMENT,
  name       VARCHAR(255) NOT NULL,
  address    TEXT NOT NULL,
  city       VARCHAR(100) NOT NULL,
  latitude   DECIMAL(10,7),
  longitude  DECIMAL(10,7),
  is_active  BOOLEAN DEFAULT true,
  createdAt  DATETIME,
  updatedAt  DATETIME
);
```

### Tabel Categories
```sql
CREATE TABLE Categories (
  id            INT PRIMARY KEY AUTO_INCREMENT,
  name          VARCHAR(255) NOT NULL,
  credit_per_kg INT DEFAULT 0,
  createdAt     DATETIME,
  updatedAt     DATETIME
);
```

## Tampilan Responsive

Dashboard dirancang untuk responsif di berbagai ukuran layar:
- ✓ Desktop (1200px+): 2 kolom layout
- ✓ Tablet (768px - 1199px): 1 kolom layout
- ✓ Mobile (<768px): Stack layout dengan navigasi yang dioptimalkan

## Error Handling

Aplikasi memiliki error handling yang baik:
- Validasi form sebelum submit
- Pesan error yang informatif
- Konfirmasi sebelum menghapus data
- Handling error dari API

## Tips Penggunaan

1. **Tambah Lokasi dengan Koordinat**: Jika memiliki koordinat GPS, input latitude dan longitude untuk mapping yang lebih akurat

2. **Kelola Kredit**: Sesuaikan nilai "kredit per kg" untuk setiap kategori agar sistem reward seimbang

3. **Status Lokasi**: Gunakan checkbox "Aktif" untuk menonaktifkan lokasi tanpa perlu menghapusnya

4. **Testing**: Gunakan API tester (Postman, Thunder Client) untuk verifikasi API jika diperlukan

## File Struktur Frontend

```
website/src/
├── AdminDashboard.jsx          # Main component
├── AdminDashboard.css          # Dashboard styles
├── AddDonationLocation.jsx      # Location form component
├── AddDonationLocation.css      # Location form styles
├── AddProductCategory.jsx       # Category form component
├── AddProductCategory.css       # Category form styles
├── App.jsx                      # Routing (updated)
├── App.css                      # App styles (updated)
└── main.jsx
```

## Troubleshooting

### "Gagal memuat data"
- Pastikan backend server berjalan di port 5000
- Cek token autentikasi di localStorage
- Lihat console browser untuk error detail

### Form tidak bisa disubmit
- Pastikan semua field wajib terisi
- Untuk koordinat, pastikan format desimal benar (contoh: -7.797)
- Cek validasi error message di form

### Token expired
- Login ulang untuk mendapatkan token baru
- Token akan disimpan otomatis di localStorage

---

**Last Updated**: May 2026  
**Version**: 1.0.0
