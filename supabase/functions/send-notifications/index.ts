import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const ONESIGNAL_APP_ID = '6cd0104d-dd1d-411d-9852-aeddf4d96b32';
const ONESIGNAL_REST_API_KEY = Deno.env.get('ONESIGNAL_REST_API_KEY') || '';
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || '';
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';

// ─── Mesaj havuzları ─────────────────────────────────────────────────────────

const DAILY_MESSAGES = [
  { title: 'Günaydın! ☀️', body: 'Bugünkü temizlik görevin hazır. Hadi başlayalım!' },
  { title: 'Yeni Bir Gün! 🌟', body: 'Küçük bir adım, büyük bir fark. Bugünkü görevine bak!' },
  { title: 'Kahveni Al! ☕', body: 'Bugünkü sürpriz görevin seni bekliyor!' },
  { title: 'Temiz Ev, Huzurlu Gün! 🏠', body: 'Birkaç dakikayla bugünü güzel başlat.' },
];

const INACTIVE_TODAY_MESSAGES = [
  { title: 'Bugün Henüz Göreve Girmedin 👀', body: 'Sürpriz görevini açmayı unutma!' },
  { title: 'Görev Seni Bekliyor! 🎁', body: 'Bugünün temizlik sürprizini henüz açmadın.' },
  { title: 'Sadece Birkaç Dakika! ⚡', body: 'Bugünkü görevini tamamlamak için hâlâ vakit var.' },
];

const STREAK_RISK_MESSAGES = [
  { title: 'Streak\'in Tehlikede! 🔥', body: 'Bugün göreve girmezsen serinizi kaybedersiniz!' },
  { title: 'Son Şans! ⚠️', body: 'Gün bitmeden görevini tamamla, streak\'ini koru!' },
  { title: 'Pes Etme! 💪', body: 'Şimdiye kadar çok yol geldin. Bugün de devam et!' },
];

const DORMANT_MESSAGES = [
  { title: 'Seni Özledik! 😔', body: 'Bir süredir görünmüyorsun. Ev seni bekliyor!' },
  { title: 'Geri Dön! 🏠', body: 'Birkaç günlük aradan sonra küçük bir adım atma zamanı.' },
  { title: 'Neredesin? 👋', body: 'Uygulamamızı kaçırdın. Bugünkü görevini gör!' },
];

const WEEKLY_MESSAGES = {
  great: [
    { title: 'Haftanı Nasıl Geçirdin? 🏆', body: 'Geçen hafta 6-7 gün görev yaptın. Muhteşem bir performans!' },
    { title: 'Şampiyon! 🎉', body: 'Geçen hafta neredeyse her gün görevini yaptın. Bu hafta da devam!' },
  ],
  good: [
    { title: 'Güzel Bir Hafta! ⭐', body: 'Geçen hafta 3-5 gün görev yaptın. Bu hafta daha iyisini yapabilirsin!' },
    { title: 'İyi Gidiyorsun! 👏', body: 'Geçen hafta aktiftins. Bu hafta her gün görev yapmayı dene!' },
  ],
  low: [
    { title: 'Yeni Hafta, Yeni Fırsat! 🌱', body: 'Geçen hafta çok az aktiftin. Bu hafta daha fazla görev yapmayı dene!' },
    { title: 'Hadi Başlayalım! 💫', body: 'Bu hafta her gün küçük bir adım atarak büyük değişimler yarat.' },
  ],
};

const MILESTONE_MESSAGES: Record<number, { title: string; body: string }> = {
  7:   { title: '7 Günlük Seri! 🔥', body: 'Bir hafta boyunca her gün görev yaptın. Harika!' },
  14:  { title: '2 Hafta Kesintisiz! 🌟', body: '14 gün boyunca devam ettin. Gerçekten kararlısın!' },
  21:  { title: '3 Hafta Streak! 🏅', body: '21 gün artık bir alışkanlık haline geldi!' },
  30:  { title: '30 Günlük Şampiyon! 🏆', body: 'Bir ay boyunca her gün görev yaptın. İnanılmaz!' },
  60:  { title: '60 Gün! Efsane! 🥇', body: 'İki ay kesintisiz. Sen artık gerçek bir CleanLoop şampiyonusun!' },
  90:  { title: '90 Gün! Ustalaştın! 👑', body: 'Temiz ev alışkanlığı artık senin bir parçan.' },
  100: { title: '100 GÜN! 🎊', body: 'YÜZ gün kesintisiz! Bu başarı gerçekten özel!' },
  200: { title: '200 Gün! Efsaneler Zinciri! 🌈', body: 'Sen artık CleanLoop\'un efsanesisin!' },
  365: { title: '365 Gün! Tam Bir Yıl! 🎂', body: 'Bir yıl boyunca her gün görev yaptın. Sonsuz saygıyla! 🙇' },
};

// ─── Ana sunucu ──────────────────────────────────────────────────────────────

serve(async (req) => {
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
    const type = url.searchParams.get('type') || 'daily';

    console.log(`🔔 Notification job started: type=${type}`);

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY);
    const today = getIstanbulDate(0);

    // Bildirimleri açık tüm kullanıcılar
    const { data: profiles, error: profileError } = await supabase
      .from('users_profile')
      .select('user_id')
      .eq('notifications_enabled', true);

    if (profileError) throw profileError;

    const enabledUserIds: string[] = profiles?.map((u: { user_id: string }) => u.user_id) || [];
    console.log(`👥 Enabled users: ${enabledUserIds.length}`);

    if (enabledUserIds.length === 0) {
      return jsonResponse({ success: true, message: 'No enabled users.', sent: 0 });
    }

    let result: { sent: number; message?: string };

    switch (type) {
      case 'daily':
        result = await handleDaily(supabase, enabledUserIds);
        break;
      case 'inactive':
        result = await handleInactiveToday(supabase, enabledUserIds, today);
        break;
      case 'streak_risk':
        result = await handleStreakRisk(supabase, enabledUserIds, today);
        break;
      case 'milestone':
        result = await handleMilestone(supabase, enabledUserIds, today);
        break;
      case 'weekly':
        result = await handleWeekly(supabase, enabledUserIds, today);
        break;
      case 'dormant':
        result = await handleDormant(supabase, enabledUserIds, today);
        break;
      default:
        return jsonResponse({ error: `Unknown type: ${type}` }, 400);
    }

    console.log(`✅ Done: type=${type}, sent=${result.sent}`);
    return jsonResponse({ success: true, type, ...result });

  } catch (err) {
    console.error('Fatal error:', err);
    return jsonResponse({ error: (err as Error).message }, 500);
  }
});

// ─── Bildirim işleyicileri ───────────────────────────────────────────────────

/** 1. Günlük hatırlatıcı — bildirimleri açık herkese (09:00) */
async function handleDaily(
  _supabase: ReturnType<typeof createClient>,
  userIds: string[],
): Promise<{ sent: number }> {
  const msg = randomItem(DAILY_MESSAGES);
  await sendToUsers(userIds, msg.title, msg.body);
  return { sent: userIds.length };
}

/** 2. Uygulamayı açmadın — bugün daily_tasks kaydı olmayanlara (14:00) */
async function handleInactiveToday(
  supabase: ReturnType<typeof createClient>,
  enabledUserIds: string[],
  today: string,
): Promise<{ sent: number }> {
  const { data: activeTasks } = await supabase
    .from('daily_tasks')
    .select('user_id')
    .eq('date', today)
    .in('user_id', enabledUserIds);

  const activeIds = new Set((activeTasks || []).map((t: { user_id: string }) => t.user_id));
  const inactiveUsers = enabledUserIds.filter(id => !activeIds.has(id));

  if (inactiveUsers.length === 0) return { sent: 0 };

  const msg = randomItem(INACTIVE_TODAY_MESSAGES);
  await sendToUsers(inactiveUsers, msg.title, msg.body);
  return { sent: inactiveUsers.length };
}

/** 3. Streak tehlikede — dün tamamlayıp bugün henüz tamamlamamışlara (21:00) */
async function handleStreakRisk(
  supabase: ReturnType<typeof createClient>,
  enabledUserIds: string[],
  today: string,
): Promise<{ sent: number }> {
  const yesterday = getIstanbulDate(-1);

  const [{ data: completedYesterday }, { data: completedToday }] = await Promise.all([
    supabase
      .from('daily_tasks')
      .select('user_id')
      .eq('date', yesterday)
      .eq('status', 'completed')
      .in('user_id', enabledUserIds),
    supabase
      .from('daily_tasks')
      .select('user_id')
      .eq('date', today)
      .eq('status', 'completed')
      .in('user_id', enabledUserIds),
  ]);

  const doneYesterday = new Set((completedYesterday || []).map((t: { user_id: string }) => t.user_id));
  const doneToday = new Set((completedToday || []).map((t: { user_id: string }) => t.user_id));

  // Dün yaptı + bugün henüz yapmadı = streak tehlikede
  const atRiskUsers = enabledUserIds.filter(
    id => doneYesterday.has(id) && !doneToday.has(id),
  );

  if (atRiskUsers.length === 0) return { sent: 0 };

  const msg = randomItem(STREAK_RISK_MESSAGES);
  await sendToUsers(atRiskUsers, msg.title, msg.body);
  return { sent: atRiskUsers.length };
}

/** 4a. Streak milestone — 7, 14, 21, 30, 60, 90, 100, 200, 365 gün (10:00) */
async function handleMilestone(
  supabase: ReturnType<typeof createClient>,
  enabledUserIds: string[],
  today: string,
): Promise<{ sent: number }> {
  const MILESTONE_VALUES = [7, 14, 21, 30, 60, 90, 100, 200, 365];

  // Bugün tamamlayanları bul
  const { data: completedToday } = await supabase
    .from('daily_tasks')
    .select('user_id')
    .eq('date', today)
    .eq('status', 'completed')
    .in('user_id', enabledUserIds);

  const completedTodayIds = (completedToday || []).map((t: { user_id: string }) => t.user_id);
  if (completedTodayIds.length === 0) return { sent: 0 };

  // Son 365 günün tamamlanan görevlerini çek
  const oldestDate = getIstanbulDate(-365);
  const { data: allCompletions } = await supabase
    .from('daily_tasks')
    .select('user_id, date')
    .eq('status', 'completed')
    .in('user_id', completedTodayIds)
    .gte('date', oldestDate)
    .lte('date', today)
    .order('date', { ascending: false });

  // Kullanıcı bazında tarihleri grupla
  const userDatesMap: Record<string, string[]> = {};
  for (const row of (allCompletions || []) as { user_id: string; date: string }[]) {
    if (!userDatesMap[row.user_id]) userDatesMap[row.user_id] = [];
    userDatesMap[row.user_id].push(row.date);
  }

  // Her kullanıcının streak'ini hesapla
  let totalSent = 0;
  const milestoneGroups: Record<number, string[]> = {};

  for (const [userId, dates] of Object.entries(userDatesMap)) {
    const streak = calculateStreak(dates);
    if (MILESTONE_VALUES.includes(streak)) {
      if (!milestoneGroups[streak]) milestoneGroups[streak] = [];
      milestoneGroups[streak].push(userId);
    }
  }

  // Her milestone grubu için ayrı bildirim gönder
  for (const [streakStr, users] of Object.entries(milestoneGroups)) {
    const streak = parseInt(streakStr);
    const msg = MILESTONE_MESSAGES[streak];
    if (msg && users.length > 0) {
      await sendToUsers(users, msg.title, msg.body);
      totalSent += users.length;
      console.log(`🏆 Milestone ${streak} days: ${users.length} users`);
    }
  }

  return { sent: totalSent };
}

/** 4b. Haftalık özet — herkese Pazartesi sabahı (09:00) */
async function handleWeekly(
  supabase: ReturnType<typeof createClient>,
  enabledUserIds: string[],
  today: string,
): Promise<{ sent: number }> {
  const sevenDaysAgo = getIstanbulDate(-7);

  const { data: weekTasks } = await supabase
    .from('daily_tasks')
    .select('user_id')
    .eq('status', 'completed')
    .in('user_id', enabledUserIds)
    .gte('date', sevenDaysAgo)
    .lt('date', today);

  // Kullanıcı başına tamamlama sayısı
  const userCount: Record<string, number> = {};
  for (const row of (weekTasks || []) as { user_id: string }[]) {
    userCount[row.user_id] = (userCount[row.user_id] || 0) + 1;
  }

  const great: string[] = [];
  const good: string[] = [];
  const low: string[] = [];

  for (const userId of enabledUserIds) {
    const count = userCount[userId] || 0;
    if (count >= 6) great.push(userId);
    else if (count >= 3) good.push(userId);
    else low.push(userId);
  }

  let totalSent = 0;

  if (great.length > 0) {
    const msg = randomItem(WEEKLY_MESSAGES.great);
    await sendToUsers(great, msg.title, msg.body);
    totalSent += great.length;
  }
  if (good.length > 0) {
    const msg = randomItem(WEEKLY_MESSAGES.good);
    await sendToUsers(good, msg.title, msg.body);
    totalSent += good.length;
  }
  if (low.length > 0) {
    const msg = randomItem(WEEKLY_MESSAGES.low);
    await sendToUsers(low, msg.title, msg.body);
    totalSent += low.length;
  }

  console.log(`📊 Weekly: great=${great.length}, good=${good.length}, low=${low.length}`);
  return { sent: totalSent };
}

/** 4c. Yeniden kazanım — 3+ gündür hiç görev açmayanlara (12:00) */
async function handleDormant(
  supabase: ReturnType<typeof createClient>,
  enabledUserIds: string[],
  today: string,
): Promise<{ sent: number }> {
  const threeDaysAgo = getIstanbulDate(-3);
  const yesterday = getIstanbulDate(-1);

  // Son 3 günde herhangi bir kaydı olanlar
  const { data: recentActivity } = await supabase
    .from('daily_tasks')
    .select('user_id')
    .in('user_id', enabledUserIds)
    .gte('date', threeDaysAgo)
    .lte('date', yesterday);

  const recentIds = new Set((recentActivity || []).map((t: { user_id: string }) => t.user_id));

  // Bugün de aktif değilse dormant say
  const { data: todayActivity } = await supabase
    .from('daily_tasks')
    .select('user_id')
    .eq('date', today)
    .in('user_id', enabledUserIds);

  const todayIds = new Set((todayActivity || []).map((t: { user_id: string }) => t.user_id));

  const dormantUsers = enabledUserIds.filter(
    id => !recentIds.has(id) && !todayIds.has(id),
  );

  if (dormantUsers.length === 0) return { sent: 0 };

  const msg = randomItem(DORMANT_MESSAGES);
  await sendToUsers(dormantUsers, msg.title, msg.body);
  return { sent: dormantUsers.length };
}

// ─── Yardımcılar ─────────────────────────────────────────────────────────────

/** Istanbul saatine göre tarihi al (offsetDays: 0=bugün, -1=dün, vb.) */
function getIstanbulDate(offsetDays: number): string {
  const now = new Date();
  const istanbul = new Date(now.getTime() + 3 * 60 * 60 * 1000);
  istanbul.setDate(istanbul.getDate() + offsetDays);
  return istanbul.toISOString().split('T')[0];
}

/** Azalan sıralı tarih dizisinden ardışık streak hesapla */
function calculateStreak(sortedDatesDesc: string[]): number {
  if (sortedDatesDesc.length === 0) return 0;

  let streak = 0;
  let expected = getIstanbulDate(0);

  for (const dateStr of sortedDatesDesc) {
    if (dateStr === expected) {
      streak++;
      // Bir önceki günü hesapla
      const d = new Date(expected + 'T00:00:00Z');
      d.setDate(d.getDate() - 1);
      expected = d.toISOString().split('T')[0];
    } else {
      break;
    }
  }

  return streak;
}

/** Diziden rastgele eleman seç */
function randomItem<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

/** OneSignal push bildirimi gönder */
async function sendToUsers(userIds: string[], title: string, body: string): Promise<void> {
  if (userIds.length === 0) return;
  if (!ONESIGNAL_REST_API_KEY) throw new Error('ONESIGNAL_REST_API_KEY is not set');

  const response = await fetch('https://onesignal.com/api/v1/notifications', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Basic ${ONESIGNAL_REST_API_KEY}`,
    },
    body: JSON.stringify({
      app_id: ONESIGNAL_APP_ID,
      include_external_user_ids: userIds,
      target_channel: 'push',
      headings: { en: title, tr: title },
      contents: { en: body, tr: body },
      priority: 10,
      ios_badgeType: 'Increase',
      ios_badgeCount: 1,
    }),
  });

  const result = await response.json();
  if (!response.ok) throw new Error(`OneSignal error: ${JSON.stringify(result)}`);
  console.log(`📨 Sent to ${userIds.length} users | id=${result.id}`);
}

/** JSON response helper */
function jsonResponse(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
