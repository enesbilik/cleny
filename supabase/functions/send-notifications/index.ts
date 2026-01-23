import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const ONESIGNAL_APP_ID = '6cd0104d-dd1d-411d-9852-aeddf4d96b32';
const ONESIGNAL_REST_API_KEY = Deno.env.get('ONESIGNAL_REST_API_KEY') || '';

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || '';
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';

// Motivasyon mesajları
const MORNING_MESSAGES = [
  { title: 'Günaydın! ☀️', body: 'Bugün küçük bir adım, büyük bir fark!' },
  { title: 'Yeni Gün, Yeni Fırsat! 🌟', body: '10 dakikada evini değiştir!' },
  { title: 'Kahveni Al! ☕', body: 'Bugünün görevi seni bekliyor!' },
];

const REMINDER_MESSAGES = [
  { title: 'Görev Zamanı! 🎁', body: 'Bugünün sürprizi hazır, aç ve başla!' },
  { title: 'Molana 10 Dakika Ekle 🧹', body: 'Temizlik yap, sonra rahatlık!' },
  { title: 'Netflix Bekleyebilir 📺', body: 'Önce görev, sonra dizi!' },
];

const EVENING_MESSAGES = [
  { title: 'Son Şans! 🔥', body: 'Streak\'ini kaybetmemek için 10 dakika!' },
  { title: 'Gün Bitmeden! ⏰', body: 'Görevini tamamla, rahat uyu!' },
  { title: 'Streak Tehlikede! ⚠️', body: 'Bugün de devam et, şampiyon!' },
];

const LATE_NIGHT_MESSAGES = [
  { title: 'SON 3 SAAT! 🆘', body: 'Streak kaybetmek üzeresin!' },
  { title: 'Sadece 10 Dakika! 💪', body: 'Yarın kendine teşekkür edeceksin!' },
];

serve(async (req) => {
  // CORS
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      },
    });
  }

  try {
    const url = new URL(req.url);
    const notificationType = url.searchParams.get('type') || 'reminder';

    console.log(`🔔 Notification job started: ${notificationType}`);

    // Supabase client (service role)
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);

    // Bugünün tarihini al (Istanbul timezone)
    const today = getTodayInIstanbul();

    // Bugün görevini TAMAMLAMAMIŞ kullanıcıları bul
    const { data: incompleteTasks, error } = await supabase
      .from('daily_tasks')
      .select('user_id')
      .eq('date', today)
      .neq('status', 'completed');

    if (error) {
      console.error('Database error:', error);
      return new Response(JSON.stringify({ error: error.message }), { status: 500 });
    }

    const incompleteUserIds = incompleteTasks?.map(t => t.user_id) || [];
    console.log(`📊 Users with incomplete tasks: ${incompleteUserIds.length}`);

    if (incompleteUserIds.length === 0) {
      return new Response(JSON.stringify({ 
        success: true, 
        message: 'All users completed their tasks! 🎉',
        sent: 0 
      }));
    }

    // Mesaj seç
    let messages: { title: string; body: string }[];
    switch (notificationType) {
      case 'morning':
        messages = MORNING_MESSAGES;
        break;
      case 'evening':
        messages = EVENING_MESSAGES;
        break;
      case 'late':
        messages = LATE_NIGHT_MESSAGES;
        break;
      default:
        messages = REMINDER_MESSAGES;
    }

    const randomMessage = messages[Math.floor(Math.random() * messages.length)];

    // OneSignal'a bildirim gönder
    const notificationResult = await sendOneSignalNotification(
      incompleteUserIds,
      randomMessage.title,
      randomMessage.body
    );

    console.log(`✅ Notification sent to ${incompleteUserIds.length} users`);

    return new Response(JSON.stringify({
      success: true,
      type: notificationType,
      usersNotified: incompleteUserIds.length,
      message: randomMessage,
      onesignalResponse: notificationResult,
    }), {
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error) {
    console.error('Error:', error);
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});

// Istanbul timezone'da bugünün tarihini al
function getTodayInIstanbul(): string {
  const now = new Date();
  const istanbul = new Date(now.getTime() + 3 * 60 * 60 * 1000);
  return istanbul.toISOString().split('T')[0];
}

// OneSignal API ile bildirim gönder
async function sendOneSignalNotification(
  userIds: string[],
  title: string,
  body: string
): Promise<any> {
  if (!ONESIGNAL_REST_API_KEY) {
    throw new Error('ONESIGNAL_REST_API_KEY is not set');
  }

  const response = await fetch('https://onesignal.com/api/v1/notifications', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`,
    },
    body: JSON.stringify({
      app_id: ONESIGNAL_APP_ID,
      // External User IDs (Supabase user_id'leri) - OneSignal'da login() ile kaydedilen ID'ler
      include_external_user_ids: userIds,
      target_channel: 'push',
      headings: { en: title, tr: title },
      contents: { en: body, tr: body },
      // Android ayarları
      priority: 10,
      // iOS ayarları
      ios_badgeType: 'Increase',
      ios_badgeCount: 1,
    }),
  });

  const result = await response.json();
  
  if (!response.ok) {
    console.error('OneSignal API Error:', result);
    throw new Error(`OneSignal API error: ${JSON.stringify(result)}`);
  }

  return result;
}

