-- CleanLoop MVP - Task Catalog Seed Data
-- Bu dosyayı schema.sql'den SONRA çalıştırın

-- Mevcut verileri temizle
DELETE FROM tasks_catalog;

-- Görev kataloğunu ekle (Tüm görevler 15 dakika)
INSERT INTO tasks_catalog (id, title, description, estimated_minutes, task_type, room_scope, difficulty, icon_key) VALUES
    ('vacuum_living', 'Salon Süpürme', 'Salonun zeminini elektrikli süpürge ile temizle. Koltukların altını da unutma!', 15, 'vacuum', 'ROOM_REQUIRED', 1, 'vacuum'),
    ('vacuum_bedroom', 'Yatak Odası Süpürme', 'Yatak odasının zeminini süpür. Yatağın altına da bak!', 15, 'vacuum', 'ROOM_REQUIRED', 1, 'vacuum'),
    ('wipe_surfaces', 'Yüzey Silme', 'Masa, sehpa ve rafların üzerini nemli bezle sil.', 15, 'wipe', 'ROOM_REQUIRED', 1, 'wipe'),
    ('wipe_kitchen_counter', 'Mutfak Tezgahı', 'Mutfak tezgahını iyice sil ve düzenle. Eşyaları yerlerine koy.', 15, 'kitchen', 'ROOM_OPTIONAL', 1, 'kitchen'),
    ('tidy_living', 'Salon Toparlama', 'Salondaki dağınıklığı topla. Yastıkları düzelt, kumandaları yerleştir.', 15, 'tidy', 'ROOM_REQUIRED', 1, 'tidy'),
    ('tidy_bedroom', 'Yatak Odası Toparlama', 'Yatağı düzelt, kıyafetleri yerleştir, komodini topla.', 15, 'tidy', 'ROOM_REQUIRED', 1, 'tidy'),
    ('trash_collect', 'Çöp Toplama', 'Evdeki tüm çöp kutularını kontrol et ve dolu olanları değiştir.', 15, 'trash', 'ROOM_OPTIONAL', 1, 'trash'),
    ('trash_recycle', 'Geri Dönüşüm Düzenleme', 'Geri dönüşüm kutusunu düzenle, karışık atıkları ayır.', 15, 'trash', 'ROOM_OPTIONAL', 1, 'trash'),
    ('kitchen_dishes', 'Bulaşık Düzeni', 'Bulaşık makinesini boşalt veya lavabodaki bulaşıkları yıka.', 15, 'kitchen', 'ROOM_OPTIONAL', 2, 'kitchen'),
    ('kitchen_stove', 'Ocak Temizliği', 'Ocak üstünü ve çevresini temizle. Yağ lekelerini sil.', 15, 'kitchen', 'ROOM_OPTIONAL', 2, 'kitchen'),
    ('kitchen_fridge', 'Buzdolabı Kontrolü', 'Buzdolabını kontrol et, bozulmuş yiyecekleri at, rafları düzenle.', 15, 'kitchen', 'ROOM_OPTIONAL', 2, 'kitchen'),
    ('laundry_sort', 'Çamaşır Ayırma', 'Kirli çamaşırları renklerine göre ayır, makineye at.', 15, 'laundry', 'ROOM_OPTIONAL', 1, 'laundry'),
    ('laundry_fold', 'Çamaşır Katlama', 'Kurumuş çamaşırları katla ve yerlerine koy.', 15, 'laundry', 'ROOM_OPTIONAL', 2, 'laundry'),
    ('laundry_iron', 'Ütü Zamanı', 'Birkaç parça kıyafeti ütüle ve dolaba as.', 15, 'laundry', 'ROOM_OPTIONAL', 2, 'laundry'),
    ('bath_sink', 'Lavabo Temizliği', 'Banyo lavabosunu ve aynayı temizle, parlatıcı kullan.', 15, 'bath', 'ROOM_OPTIONAL', 1, 'bath'),
    ('bath_toilet', 'Tuvalet Temizliği', 'Tuvaleti fırçala ve dışını sil. Zemine de bak.', 15, 'bath', 'ROOM_OPTIONAL', 2, 'bath'),
    ('bath_shower', 'Duş Temizliği', 'Duşakabin veya küvet yüzeylerini temizle, kireç lekelerini sil.', 15, 'bath', 'ROOM_OPTIONAL', 2, 'bath'),
    ('dust_shelves', 'Raf Toz Alma', 'Kitaplık ve rafların tozunu al, eşyaları düzenle.', 15, 'dust', 'ROOM_REQUIRED', 1, 'dust'),
    ('dust_electronics', 'Elektronik Temizliği', 'TV, bilgisayar ve diğer elektroniklerin tozunu mikrofiber bezle al.', 15, 'dust', 'ROOM_REQUIRED', 1, 'dust'),
    ('dust_decor', 'Dekorasyon Temizliği', 'Vazo, çerçeve ve dekoratif eşyaların tozunu al.', 15, 'dust', 'ROOM_REQUIRED', 1, 'dust'),
    ('tidy_closet', 'Dolap Düzeni', 'Bir dolabı veya çekmeceyi düzenle, gereksizleri ayır.', 15, 'tidy', 'ROOM_REQUIRED', 2, 'tidy'),
    ('tidy_desk', 'Çalışma Masası Düzeni', 'Çalışma masanı temizle ve düzenle. Kağıtları ayır.', 15, 'tidy', 'ROOM_REQUIRED', 1, 'tidy'),
    ('wipe_doors', 'Kapı Kolu Silme', 'Evdeki tüm kapı kollarını ve ışık düğmelerini dezenfekte et.', 15, 'wipe', 'ROOM_OPTIONAL', 1, 'wipe'),
    ('wipe_windows', 'Pencere Silme', 'Bir odanın pencerelerini iç taraftan sil.', 15, 'wipe', 'ROOM_REQUIRED', 2, 'wipe'),
    ('vacuum_carpet', 'Halı Süpürme', 'Halı veya kilimin üzerini dikkatlice süpür, kenarları da geç.', 15, 'vacuum', 'ROOM_REQUIRED', 1, 'vacuum');

-- Verify
SELECT COUNT(*) as task_count FROM tasks_catalog;

