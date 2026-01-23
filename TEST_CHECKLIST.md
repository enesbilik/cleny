# CleanLoop MVP Test Checklist

Bu dosya, uygulamanın tüm özelliklerini test etmek için kullanılacak kontrol listesidir.

---

## 1. Kurulum ve Çalıştırma

- [ ] Flutter projesi hatasız derleniyor (Android)
- [ ] Flutter projesi hatasız derleniyor (iOS)
- [ ] Supabase bağlantısı çalışıyor
- [ ] Edge Functions deploy edildi
- [ ] .env dosyası doğru yapılandırıldı

---

## 2. Authentication (Kimlik Doğrulama)

### Email Auth
- [ ] Yeni hesap oluşturulabiliyor (kayıt)
- [ ] Email doğrulama maili gidiyor
- [ ] Mevcut hesapla giriş yapılabiliyor
- [ ] Yanlış şifre ile giriş reddediliyor
- [ ] Şifre sıfırlama emaili gönderilebiliyor

### Google Auth
- [ ] Google ile giriş butonu çalışıyor
- [ ] OAuth akışı tamamlanıyor
- [ ] Kullanıcı bilgileri alınıyor

### Apple Auth (Sadece iOS)
- [ ] Apple ile giriş butonu görünüyor
- [ ] OAuth akışı tamamlanıyor
- [ ] Kullanıcı bilgileri alınıyor

### Anonim Auth
- [ ] "Kayıt olmadan devam et" çalışıyor
- [ ] Anonim kullanıcı oluşturuluyor

### Genel
- [ ] Çıkış yapılabiliyor
- [ ] Token süresi dolunca yenileniyor
- [ ] Auth state değişiklikleri dinleniyor

---

## 3. Onboarding

### Welcome Ekranı
- [ ] Animasyonlar düzgün çalışıyor
- [ ] "Başlayalım" butonu çalışıyor

### Oda Seçimi
- [ ] Hazır oda şablonları görünüyor
- [ ] Oda eklenebiliyor
- [ ] Özel oda adı girilebiliyor
- [ ] Oda silinebiliyor (en az 1 kalmalı)
- [ ] Maksimum 10 oda sınırı çalışıyor

### Saat Seçimi
- [ ] Time picker açılıyor
- [ ] Başlangıç saati seçilebiliyor
- [ ] Bitiş saati seçilebiliyor
- [ ] Bitiş > Başlangıç kontrolü yapılıyor

### Süre Seçimi
- [ ] 10 dakika seçeneği var
- [ ] 15 dakika seçeneği var
- [ ] Seçim görsel olarak belirgin

### Tamamlama
- [ ] "Temizliğe Başla" butonu çalışıyor
- [ ] Veriler Supabase'e kaydediliyor
- [ ] Onboarding flag'i set ediliyor
- [ ] Ana ekrana yönlendiriliyor

---

## 4. Ana Ekran (Home)

### Üst Kısım
- [ ] Selamlama mesajı görünüyor
- [ ] Streak badge görünüyor
- [ ] Streak sayısı doğru

### Ev Görseli
- [ ] Ev illustrasyonu görünüyor
- [ ] Temizlik seviyesine göre renk değişiyor
- [ ] Yüksek seviyelerde parıltı efekti var

### Durum Mesajı
- [ ] Seviyeye göre mesaj değişiyor
- [ ] Açıklama metni görünüyor

### Günlük Görev Kartı
- [ ] "Bugünün sürprizi hazır" görünüyor
- [ ] Hediye kutusu görseli var
- [ ] "Aç" butonu çalışıyor

### Görev Açıldıktan Sonra
- [ ] Görev başlığı görünüyor
- [ ] Görev süresi görünüyor
- [ ] Oda bilgisi görünüyor (varsa)
- [ ] "Başlat" butonu çalışıyor

### Tamamlanmış Görev
- [ ] Yeşil tamamlandı kartı görünüyor
- [ ] "Yarın yeni sürpriz" mesajı var

### Bottom Navigation
- [ ] "Evim" tab'ı aktif
- [ ] "İstatistik" tab'ı çalışıyor
- [ ] "Ayarlar" tab'ı çalışıyor

---

## 5. Timer Ekranı

### Başlamadan Önce
- [ ] Timer 00:00'dan başlamıyor (10 veya 15 dk)
- [ ] "Başlat" butonu görünüyor
- [ ] Kapat butonu çalışıyor

### Çalışırken
- [ ] Countdown doğru çalışıyor
- [ ] "Durdur" butonu görünüyor
- [ ] Progress ring ilerliyor

### Duraklatıldığında
- [ ] Timer duruyor
- [ ] "Devam" butonu görünüyor

### Süre Dolduğunda
- [ ] "Süre doldu" mesajı görünüyor
- [ ] "Basılı tut ve temizle" butonu aktif

### Erken Tamamlama
- [ ] "Erken tamamla" butonu var
- [ ] Onay dialogu açılıyor

---

## 6. Tamamlama Ekranı

### Gösterim
- [ ] Parçacık animasyonları var
- [ ] Check ikonu animasyonu çalışıyor
- [ ] "Harika iş!" mesajı görünüyor
- [ ] "Bugünkü görev tamamlandı" mesajı var

### Aksiyon
- [ ] "Ana ekrana dön" butonu çalışıyor
- [ ] Home'a yönlendiriliyor
- [ ] Görev completed olarak işaretleniyor

---

## 7. İstatistik Tab'ı

- [ ] Güncel streak görünüyor
- [ ] En iyi streak görünüyor
- [ ] "Geçmişi Görüntüle" butonu çalışıyor

---

## 8. Takvim Ekranı

### Gösterim
- [ ] Son 14 gün görünüyor
- [ ] Tamamlanan günler yeşil
- [ ] Bugün işaretli
- [ ] Legend (açıklama) görünüyor

### İstatistikler
- [ ] Güncel streak doğru
- [ ] En iyi streak doğru
- [ ] Toplam tamamlanan doğru

---

## 9. Ayarlar Ekranı

### Profil
- [ ] Oda sayısı görünüyor
- [ ] Odalar düzenlenebiliyor
- [ ] Günlük süre değiştirilebiliyor
- [ ] Bildirim saati görünüyor

### Bildirimler
- [ ] Görev bildirimleri toggle çalışıyor
- [ ] Motivasyon bildirimleri toggle çalışıyor

### Ses
- [ ] Ses aç/kapa toggle çalışıyor

### Veri
- [ ] "Verileri Sıfırla" butonu var
- [ ] Onay dialogu açılıyor
- [ ] Sıfırlama sonrası onboarding'e gidiyor

---

## 10. Görev Seçim Algoritması

- [ ] Her gün farklı görev geliyor
- [ ] Aynı oda ardışık gelmiyor (2+ oda varsa)
- [ ] Aynı görev tipi ardışık gelmiyor
- [ ] Kural sağlanamazsa gevşetme çalışıyor
- [ ] Gün içinde görev değişmiyor

---

## 11. Bildirimler

- [ ] İzin isteme dialogu açılıyor
- [ ] İzin verilirse bildirim zamanlanıyor
- [ ] Bildirimi reddederse uygulama çalışmaya devam ediyor
- [ ] Bildirim tıklandığında uygulama açılıyor

---

## 12. API Güvenliği (Backend)

- [ ] Auth olmadan API'ye erişilemiyor (401)
- [ ] Başka kullanıcının verisine erişilemiyor
- [ ] Input validation çalışıyor
- [ ] Rate limiting aktif
- [ ] CORS headers doğru

---

## 13. Edge Cases

- [ ] İnternet yokken uygulama crash olmuyor
- [ ] Boş veri durumları handle ediliyor
- [ ] Loading state'ler görünüyor
- [ ] Hata mesajları kullanıcı dostu

---

## 14. Performans

- [ ] Uygulama hızlı açılıyor
- [ ] Animasyonlar akıcı
- [ ] Scroll performansı iyi
- [ ] Memory leak yok

---

## Test Sonuçları

| Kategori | Geçen | Kalan | Toplam |
|----------|-------|-------|--------|
| Kurulum | | | 5 |
| Auth | | | 12 |
| Onboarding | | | 14 |
| Home | | | 16 |
| Timer | | | 9 |
| Completion | | | 5 |
| İstatistik | | | 3 |
| Takvim | | | 6 |
| Ayarlar | | | 9 |
| Algoritma | | | 5 |
| Bildirimler | | | 4 |
| API Güvenliği | | | 5 |
| Edge Cases | | | 4 |
| Performans | | | 4 |
| **TOPLAM** | | | **101** |

---

## Notlar

Test sırasında karşılaşılan sorunları buraya not edin:

1. ...
2. ...
3. ...

---

*Son güncelleme: [TARİH]*

