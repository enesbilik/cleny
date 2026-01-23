import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { handleCors } from '../_shared/cors.ts';
import { createSupabaseClient, verifyUser } from '../_shared/auth.ts';
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
  validationErrorResponse,
  serverErrorResponse,
} from '../_shared/response.ts';
import {
  validateNumber,
  validateTime,
  validateAll,
} from '../_shared/validation.ts';

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

    // GET /profile - Profil bilgilerini getir
    if (method === 'GET') {
      const { data, error } = await supabase
        .from('users_profile')
        .select('*')
        .eq('user_id', userId)
        .single();

      if (error && error.code !== 'PGRST116') {
        return serverErrorResponse(error);
      }

      return successResponse(data || null);
    }

    // POST /profile - Profil oluştur veya güncelle
    if (method === 'POST' || method === 'PUT') {
      const body = await req.json();

      // Validation
      const errors = validateAll([
        validateNumber(body.preferred_minutes, 'preferred_minutes', { min: 10, max: 15 }),
        validateTime(body.available_start, 'available_start'),
        validateTime(body.available_end, 'available_end'),
      ]);

      if (errors.length > 0) {
        return validationErrorResponse(errors);
      }

      const profileData = {
        user_id: userId,
        preferred_minutes: body.preferred_minutes,
        available_start: body.available_start,
        available_end: body.available_end,
        notifications_enabled: body.notifications_enabled ?? true,
        motivation_enabled: body.motivation_enabled ?? true,
        sound_enabled: body.sound_enabled ?? true,
        timezone: body.timezone || 'Europe/Istanbul',
      };

      const { data, error } = await supabase
        .from('users_profile')
        .upsert(profileData, { onConflict: 'user_id' })
        .select()
        .single();

      if (error) {
        return serverErrorResponse(error);
      }

      return successResponse(data, method === 'POST' ? 201 : 200);
    }

    // PATCH /profile - Kısmi güncelleme
    if (method === 'PATCH') {
      const body = await req.json();
      const updates: Record<string, unknown> = {};

      // Sadece gönderilen alanları güncelle
      if (body.preferred_minutes !== undefined) {
        const error = validateNumber(body.preferred_minutes, 'preferred_minutes', { min: 10, max: 15 });
        if (error) return validationErrorResponse([error]);
        updates.preferred_minutes = body.preferred_minutes;
      }
      if (body.available_start !== undefined) {
        const error = validateTime(body.available_start, 'available_start');
        if (error) return validationErrorResponse([error]);
        updates.available_start = body.available_start;
      }
      if (body.available_end !== undefined) {
        const error = validateTime(body.available_end, 'available_end');
        if (error) return validationErrorResponse([error]);
        updates.available_end = body.available_end;
      }
      if (body.notifications_enabled !== undefined) {
        updates.notifications_enabled = body.notifications_enabled;
      }
      if (body.motivation_enabled !== undefined) {
        updates.motivation_enabled = body.motivation_enabled;
      }
      if (body.sound_enabled !== undefined) {
        updates.sound_enabled = body.sound_enabled;
      }

      if (Object.keys(updates).length === 0) {
        return errorResponse('No valid fields to update');
      }

      const { data, error } = await supabase
        .from('users_profile')
        .update(updates)
        .eq('user_id', userId)
        .select()
        .single();

      if (error) {
        return serverErrorResponse(error);
      }

      return successResponse(data);
    }

    return errorResponse('Method not allowed', 405);
  } catch (error) {
    return serverErrorResponse(error);
  }
});

