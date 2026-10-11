<<<<<<< HEAD
# 👗 KAPSÜL DOLAP — Kırklareli Yerel Hızlı Moda Platformu

> **Kırklareli Üniversitesi** öğrencileri ve yerel butikleri buluşturan; hızlı teslimat, "Kapıda Dene & Geri Ver" imkanı ve akıllı kapsül gardırop kombinleme vizyonuna sahip Flutter projesi.

---

## 📌 Proje Özeti ve Amacı
Bu uygulama, üniversite kampüsündeki öğrencilerin yerel butiklere erişimini kolaylaştırmak amacıyla tasarlanmıştır:
- **Kapsül Gardırop Felsefesi:** Birbirleriyle uyumlu az sayıda kaliteli parça ile onlarca farklı kombin yapabilme imkanı sunar.
- **Hızlı Ekspres Teslimat:** Kırklareli Merkez, Lüleburgaz, Pınarhisar ve Vize ilçelerindeki yerel butiklerden 25-40 dakika içinde kapıya teslimat.
- **Kapıda Dene & Geri Ver:** Kurye kapıda 10 dakika bekler; bedeni uymayan ürünler anında geri verilebilir.
- **Öğrenci İndirimleri:** Kırklareli Üniversitesi öğrencilerine özel kupon desteği (`KLU10`).

---

## 🛠️ Kullanılan Teknolojiler ve Mimari

- **Framework:** Flutter (Material 3)
- **Programlama Dili:** Dart 3.x
- **Veritabanı & Backend:**
  - **Firebase Core & Cloud Firestore:** Canlı bulut veritabanı senkronizasyonu
  - **Firebase Auth:** Müşteri ve butik yetkilendirme altyapısı
  - **Resilient Hybrid Database Service:** Firestore çevrimdışı olduğunda dahi kesintisiz çalışan reaktif yerel havuz (Offline Fallback & Zero-Crash Architecture)
- **State Management & Reaktivite:** Dart Broadcast Stream / StreamBuilder mimarisi

---

## 📂 Proje Dizin Yapısı (Clean Architecture)

```text
lib/
├── firebase_options.dart      # Çoklu platform Firebase konfigürasyonu
├── main.dart                  # Uygulama başlangıcı ve RootGate yönlendirmesi
├── models/                    # Veri modelleri ve JSON/Map serileştiricileri
│   ├── cart_item.dart         # Sepet kalemi modeli
│   ├── order_record.dart      # Sipariş ve kurye takip kaydı modeli
│   ├── product.dart           # Kıyafet ve kapsül kombin modeli
│   └── store.dart             # Yerel butik mağaza modeli
├── screens/                   # Uygulama ekranları
│   ├── login_screen.dart      # Öğrenci & Butik giriş ekranı
│   ├── main_shell.dart        # Alt gezinti çubuğu ve ana kabuk
│   └── tabs/                  # Modüler sekme görünümleri
│       ├── account_tab.dart   # Profil, kayıtlı adresler, geçmiş siparişler
│       ├── boutique_tab.dart  # Butik sipariş operasyonu & vitrin yönetimi
│       ├── cart_tab.dart      # Sepet, kupon indirimi, kapıda dene seçeneği
│       ├── lookbook_tab.dart  # Butik vitrini & kategori filtreleri
│       ├── stores_tab.dart    # İlçe filtreli butik keşif ekranı
│       ├── tracking_tab.dart  # Canlı GPS harita ve kurye takip ekranı
│       └── wishlist_tab.dart  # Favoriler ve kapsül dolap paylaşımı
├── services/                  # İş mantığı ve veri katmanı
│   ├── auth_service.dart      # Kimlik doğrulama servisi
│   └── database_service.dart  # Hibrit Firestore & reaktif yerel veritabanı
├── theme/                     # Tasarım sistemi
│   ├── app_colors.dart        # Lüks sıcak editorial renk paleti
│   └── app_theme.dart         # ThemeData ve Material 3 bileşen stilleri
└── widgets/                   # Yeniden kullanılabilir görsel bileşenler
    ├── animated_hover_card.dart     # Mikro-etkileşimli kart animasyonu
    ├── delivery_dialog.dart         # 3D teslimat kutlama modalı
    ├── map_grid_painter.dart        # Canlı GPS harita ızgarası boyayıcısı
    └── safe_image.dart              # Çoklu format ve kodlama korumalı resim yükleyici
```

---

## ✨ Temel Özellikler

1. **Çift Kullanıcı Rolü (Müşteri & Butik):**
   - **Müşteri Modu:** Butik keşfi, lookbook inceleme, kombin önerileri, sepet ve canlı kurye takibi.
   - **Butik Paneli:** Günlük ciro, aktif sipariş sayısı, tek dokunuşla kurye yönlendirme, envanter yönetimi (stok aç/kapa, ürün silme, yeni ürün yükleme).
2. **Kapsül Kombin Sihirbazı:** Ürün detay sayfasında birbiriyle uyumlu yerel parçaları gösterir ve tek tıkla sepete ekler.
3. **Canlı Kurye Simülasyonu:** İstasyon Caddesi'nden Kayalı Kampüsü'ne 4 aşamalı canlı kurye ilerleme takibi ve kapıya teslim kutlama animasyonu.
4. **İndirim Kuponu Desteği:** `KLU10` (%10 Öğrenci İndirimi) ve `KAPSUL2026` (25 TL Hoş Geldin İndirimi).
5. **İstek Listesini Paylaşma:** Beğenilen kapsül parçaları tek tıkla panoya şık bir metin olarak kopyalar.

---

## 🔑 Demo & Sunum Giriş Bilgileri

Hızlı test ve hocaya sunum amacıyla giriş ekranında **tek tıkla doldurma** kısayolları eklenmiştir:

| Rol | E-Posta | Şifre / PIN |
|---|---|---|
| **Öğrenci (Müşteri)** | `zeynep@klu.edu.tr` | `123456` |
| **Butik Yetkilisi** | `istasyon@butik.kapsul.com` | `3939` (PIN) |
| **Misafir** | Butikleri Keşfet düğmesi ile şifresiz giriş |

---

## 🚀 Kurulum ve Çalıştırma

Projeyi yerel ortamınızda çalıştırmak için:

```bash
# 1. Bağımlılıkları yükleyin
flutter pub get

# 2. Kod analizi ve testleri çalıştırın
flutter analyze
flutter test

# 3. Uygulamayı başlatın (Chrome, Windows veya Emulator)
flutter run
```

---

*© 2026 Kapsül Dolap — Kırklareli Üniversitesi Yerel Moda İnisiyatifi Projesi*
=======
# Dolap
Kapsul dolap
>>>>>>> a53d57a42df4ed84f7c46ffda3cc58406ac08035
