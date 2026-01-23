import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// Supabase client oluştur
export function createSupabaseClient(req: Request) {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
  
  const authHeader = req.headers.get('Authorization');
  
  return createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: {
        Authorization: authHeader || '',
      },
    },
  });
}

// Kullanıcıyı doğrula ve ID'sini al
export async function verifyUser(req: Request): Promise<{ userId: string | null; error: string | null }> {
  const supabase = createSupabaseClient(req);
  
  const { data: { user }, error } = await supabase.auth.getUser();
  
  if (error || !user) {
    return { userId: null, error: 'Unauthorized' };
  }
  
  return { userId: user.id, error: null };
}

// Admin client (service role ile)
export function createAdminClient() {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
  
  return createClient(supabaseUrl, serviceRoleKey);
}

