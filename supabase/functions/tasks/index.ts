import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { handleCors } from '../_shared/cors.ts';
import { createSupabaseClient, verifyUser } from '../_shared/auth.ts';
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
  notFoundResponse,
  serverErrorResponse,
} from '../_shared/response.ts';

serve(async (req) => {
  // CORS
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Auth kontrolü
    const { userId, error: authError } = await verifyUser(req);
    if (authError || !userId) {
      return unauthorizedResponse();
    }

    const supabase = createSupabaseClient(req);
    const url = new URL(req.url);
    const method = req.method;
    const action = url.searchParams.get('action');

    // GET /tasks?action=today - Bugünün görevini getir veya oluştur
    if (method === 'GET' && action === 'today') {
      const today = getTodayInIstanbul();

      // Bugünün görevi var mı?
      let { data: existingTask } = await supabase
        .from('daily_tasks')
        .select('*, tasks_catalog(*), rooms(*)')
        .eq('user_id', userId)
        .eq('date', today)
        .single();

      if (existingTask) {
        return successResponse(existingTask);
      }

      // Yeni görev oluştur
      const newTask = await createDailyTask(supabase, userId, today);
      if (!newTask) {
        return errorResponse('Could not create daily task');
      }

      // Oluşturulan görevi detaylı getir
      const { data: taskWithDetails } = await supabase
        .from('daily_tasks')
        .select('*, tasks_catalog(*), rooms(*)')
        .eq('id', newTask.id)
        .single();

      return successResponse(taskWithDetails);
    }

    // GET /tasks?action=history - Görev geçmişi
    if (method === 'GET' && action === 'history') {
      const days = parseInt(url.searchParams.get('days') || '14');
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      const { data, error } = await supabase
        .from('daily_tasks')
        .select('id, date, status, completed_at')
        .eq('user_id', userId)
        .gte('date', startDate.toISOString().split('T')[0])
        .order('date', { ascending: false });

      if (error) {
        return serverErrorResponse(error);
      }

      return successResponse(data);
    }

    // GET /tasks?action=stats - İstatistikler
    if (method === 'GET' && action === 'stats') {
      const { data: completedTasks, error } = await supabase
        .from('daily_tasks')
        .select('date')
        .eq('user_id', userId)
        .eq('status', 'completed')
        .order('date', { ascending: false });

      if (error) {
        return serverErrorResponse(error);
      }

      const completedDates = completedTasks?.map(t => t.date) || [];
      const stats = calculateStats(completedDates);

      return successResponse(stats);
    }

    // GET /tasks/catalog - Görev kataloğunu getir
    if (method === 'GET' && action === 'catalog') {
      const { data, error } = await supabase
        .from('tasks_catalog')
        .select('*');

      if (error) {
        return serverErrorResponse(error);
      }

      return successResponse(data);
    }

    // POST /tasks/:id/complete - Görevi tamamla
    if (method === 'POST' && action === 'complete') {
      const taskId = url.searchParams.get('taskId');
      if (!taskId) {
        return errorResponse('Task ID is required');
      }

      const body = await req.json().catch(() => ({}));

      const { data, error } = await supabase
        .from('daily_tasks')
        .update({
          status: 'completed',
          completed_at: new Date().toISOString(),
          completion_method: body.completion_method || 'hold_clean',
          duration_seconds: body.duration_seconds,
        })
        .eq('id', taskId)
        .eq('user_id', userId)
        .select()
        .single();

      if (error) {
        return notFoundResponse('Task');
      }

      return successResponse(data);
    }

    return errorResponse('Method not allowed', 405);
  } catch (error) {
    return serverErrorResponse(error);
  }
});

// Bugünün tarihini Istanbul timezone'ında al
function getTodayInIstanbul(): string {
  const now = new Date();
  // Istanbul UTC+3
  const istanbul = new Date(now.getTime() + 3 * 60 * 60 * 1000);
  return istanbul.toISOString().split('T')[0];
}

// Günlük görev oluştur
async function createDailyTask(supabase: any, userId: string, date: string) {
  // Kullanıcının odalarını al
  const { data: rooms } = await supabase
    .from('rooms')
    .select('id, name')
    .eq('user_id', userId);

  if (!rooms || rooms.length === 0) {
    return null;
  }

  // Görev kataloğunu al
  const { data: catalog } = await supabase
    .from('tasks_catalog')
    .select('*');

  if (!catalog || catalog.length === 0) {
    return null;
  }

  // Son görevleri al
  const { data: recentTasks } = await supabase
    .from('daily_tasks')
    .select('task_catalog_id, room_id')
    .eq('user_id', userId)
    .order('date', { ascending: false })
    .limit(7);

  // Son kullanılan oda ve görev tiplerini bul
  const recentRoomIds = new Set(recentTasks?.slice(0, 1).map((t: any) => t.room_id).filter(Boolean));
  const recentTaskIds = new Set(recentTasks?.slice(0, 1).map((t: any) => t.task_catalog_id));

  // Uygun görevleri filtrele
  let availableTasks = catalog.filter((t: any) => !recentTaskIds.has(t.id));
  if (availableTasks.length === 0) {
    availableTasks = catalog;
  }

  // Uygun odaları filtrele
  let availableRooms = rooms.filter((r: any) => !recentRoomIds.has(r.id));
  if (availableRooms.length === 0) {
    availableRooms = rooms;
  }

  // Rastgele seç
  const selectedTask = availableTasks[Math.floor(Math.random() * availableTasks.length)];
  const selectedRoom = selectedTask.room_scope === 'ROOM_REQUIRED'
    ? availableRooms[Math.floor(Math.random() * availableRooms.length)]
    : (Math.random() > 0.5 ? availableRooms[Math.floor(Math.random() * availableRooms.length)] : null);

  // Görevi oluştur
  const { data: newTask, error } = await supabase
    .from('daily_tasks')
    .insert({
      user_id: userId,
      date: date,
      task_catalog_id: selectedTask.id,
      room_id: selectedRoom?.id || null,
      status: 'assigned',
    })
    .select()
    .single();

  if (error) {
    console.error('Error creating task:', error);
    return null;
  }

  return newTask;
}

// İstatistikleri hesapla
function calculateStats(completedDates: string[]) {
  const today = getTodayInIstanbul();
  const todayDate = new Date(today);
  
  // Current streak
  let currentStreak = 0;
  let checkDate = new Date(todayDate);
  
  // Bugün tamamlanmadıysa dünden başla
  if (!completedDates.includes(today)) {
    checkDate.setDate(checkDate.getDate() - 1);
  }
  
  while (completedDates.includes(checkDate.toISOString().split('T')[0])) {
    currentStreak++;
    checkDate.setDate(checkDate.getDate() - 1);
  }

  // Best streak
  let bestStreak = 0;
  let tempStreak = 0;
  const sortedDates = [...completedDates].sort();
  
  for (let i = 0; i < sortedDates.length; i++) {
    if (i === 0) {
      tempStreak = 1;
    } else {
      const prevDate = new Date(sortedDates[i - 1]);
      const currDate = new Date(sortedDates[i]);
      const diff = (currDate.getTime() - prevDate.getTime()) / (1000 * 60 * 60 * 24);
      
      if (diff === 1) {
        tempStreak++;
      } else {
        if (tempStreak > bestStreak) bestStreak = tempStreak;
        tempStreak = 1;
      }
    }
  }
  if (tempStreak > bestStreak) bestStreak = tempStreak;

  // Son 7 gündeki tamamlama sayısı
  const sevenDaysAgo = new Date(todayDate);
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
  const last7Days = completedDates.filter(d => new Date(d) >= sevenDaysAgo).length;

  // Temizlik seviyesi (0-4)
  let cleanlinessLevel = 0;
  if (last7Days >= 6) cleanlinessLevel = 4;
  else if (last7Days >= 5) cleanlinessLevel = 3;
  else if (last7Days >= 3) cleanlinessLevel = 2;
  else if (last7Days >= 2) cleanlinessLevel = 1;

  return {
    currentStreak,
    bestStreak,
    totalCompleted: completedDates.length,
    last7DaysCompleted: last7Days,
    cleanlinessLevel,
  };
}

