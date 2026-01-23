import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { handleCors } from '../_shared/cors.ts';
import { createSupabaseClient, verifyUser } from '../_shared/auth.ts';
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
  validationErrorResponse,
  notFoundResponse,
  serverErrorResponse,
} from '../_shared/response.ts';
import {
  validateString,
  validateArray,
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
    const pathParts = url.pathname.split('/').filter(Boolean);
    const roomId = pathParts[1]; // /rooms/{id}

    // GET /rooms - Tüm odaları getir
    if (method === 'GET' && !roomId) {
      const { data, error } = await supabase
        .from('rooms')
        .select('*')
        .eq('user_id', userId)
        .order('sort_order');

      if (error) {
        return serverErrorResponse(error);
      }

      return successResponse(data);
    }

    // GET /rooms/:id - Tek oda getir
    if (method === 'GET' && roomId) {
      const { data, error } = await supabase
        .from('rooms')
        .select('*')
        .eq('id', roomId)
        .eq('user_id', userId)
        .single();

      if (error) {
        return notFoundResponse('Room');
      }

      return successResponse(data);
    }

    // POST /rooms - Oda ekle
    if (method === 'POST' && !roomId) {
      const body = await req.json();

      // Tek oda mı çoklu oda mı?
      if (Array.isArray(body.rooms)) {
        // Çoklu oda ekleme
        const errors = validateAll([
          validateArray(body.rooms, 'rooms', { minLength: 1, maxLength: 10 }),
        ]);

        if (errors.length > 0) {
          return validationErrorResponse(errors);
        }

        // Her oda için validation
        for (let i = 0; i < body.rooms.length; i++) {
          const roomError = validateString(body.rooms[i], `rooms[${i}]`, { minLength: 1, maxLength: 50 });
          if (roomError) {
            return validationErrorResponse([roomError]);
          }
        }

        // Mevcut odaları sil
        await supabase.from('rooms').delete().eq('user_id', userId);

        // Yeni odaları ekle
        const roomsData = body.rooms.map((name: string, index: number) => ({
          user_id: userId,
          name: name.trim(),
          sort_order: index,
        }));

        const { data, error } = await supabase
          .from('rooms')
          .insert(roomsData)
          .select();

        if (error) {
          return serverErrorResponse(error);
        }

        return successResponse(data, 201);
      } else {
        // Tek oda ekleme
        const errors = validateAll([
          validateString(body.name, 'name', { minLength: 1, maxLength: 50 }),
        ]);

        if (errors.length > 0) {
          return validationErrorResponse(errors);
        }

        // Mevcut oda sayısını kontrol et
        const { count } = await supabase
          .from('rooms')
          .select('*', { count: 'exact', head: true })
          .eq('user_id', userId);

        if (count && count >= 10) {
          return errorResponse('Maximum 10 rooms allowed');
        }

        const { data, error } = await supabase
          .from('rooms')
          .insert({
            user_id: userId,
            name: body.name.trim(),
            sort_order: count || 0,
          })
          .select()
          .single();

        if (error) {
          return serverErrorResponse(error);
        }

        return successResponse(data, 201);
      }
    }

    // PUT /rooms/:id - Oda güncelle
    if (method === 'PUT' && roomId) {
      const body = await req.json();

      const errors = validateAll([
        validateString(body.name, 'name', { minLength: 1, maxLength: 50 }),
      ]);

      if (errors.length > 0) {
        return validationErrorResponse(errors);
      }

      const { data, error } = await supabase
        .from('rooms')
        .update({ name: body.name.trim() })
        .eq('id', roomId)
        .eq('user_id', userId)
        .select()
        .single();

      if (error) {
        return notFoundResponse('Room');
      }

      return successResponse(data);
    }

    // DELETE /rooms/:id - Oda sil
    if (method === 'DELETE' && roomId) {
      // En az 1 oda kalmalı
      const { count } = await supabase
        .from('rooms')
        .select('*', { count: 'exact', head: true })
        .eq('user_id', userId);

      if (count && count <= 1) {
        return errorResponse('At least 1 room is required');
      }

      const { error } = await supabase
        .from('rooms')
        .delete()
        .eq('id', roomId)
        .eq('user_id', userId);

      if (error) {
        return serverErrorResponse(error);
      }

      return successResponse({ deleted: true });
    }

    return errorResponse('Method not allowed', 405);
  } catch (error) {
    return serverErrorResponse(error);
  }
});

