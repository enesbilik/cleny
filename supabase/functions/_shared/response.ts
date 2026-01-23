import { corsHeaders } from './cors.ts';

// Success response
export function successResponse(data: unknown, status = 200): Response {
  return new Response(
    JSON.stringify({ success: true, data }),
    {
      status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  );
}

// Error response
export function errorResponse(message: string, status = 400): Response {
  return new Response(
    JSON.stringify({ success: false, error: message }),
    {
      status,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  );
}

// Validation error response
export function validationErrorResponse(errors: { field: string; message: string }[]): Response {
  return new Response(
    JSON.stringify({ success: false, error: 'Validation failed', details: errors }),
    {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  );
}

// Unauthorized response
export function unauthorizedResponse(): Response {
  return errorResponse('Unauthorized', 401);
}

// Not found response
export function notFoundResponse(resource = 'Resource'): Response {
  return errorResponse(`${resource} not found`, 404);
}

// Internal server error
export function serverErrorResponse(error: unknown): Response {
  console.error('Server error:', error);
  return errorResponse('Internal server error', 500);
}

