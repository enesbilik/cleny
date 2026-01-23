// Input validation helpers

export interface ValidationError {
  field: string;
  message: string;
}

// String validation
export function validateString(
  value: unknown,
  field: string,
  options: { minLength?: number; maxLength?: number; required?: boolean } = {}
): ValidationError | null {
  const { minLength = 0, maxLength = 1000, required = true } = options;

  if (required && (value === undefined || value === null || value === '')) {
    return { field, message: `${field} is required` };
  }

  if (value !== undefined && value !== null && value !== '') {
    if (typeof value !== 'string') {
      return { field, message: `${field} must be a string` };
    }
    if (value.length < minLength) {
      return { field, message: `${field} must be at least ${minLength} characters` };
    }
    if (value.length > maxLength) {
      return { field, message: `${field} must be at most ${maxLength} characters` };
    }
  }

  return null;
}

// Number validation
export function validateNumber(
  value: unknown,
  field: string,
  options: { min?: number; max?: number; required?: boolean } = {}
): ValidationError | null {
  const { min, max, required = true } = options;

  if (required && (value === undefined || value === null)) {
    return { field, message: `${field} is required` };
  }

  if (value !== undefined && value !== null) {
    if (typeof value !== 'number' || isNaN(value)) {
      return { field, message: `${field} must be a number` };
    }
    if (min !== undefined && value < min) {
      return { field, message: `${field} must be at least ${min}` };
    }
    if (max !== undefined && value > max) {
      return { field, message: `${field} must be at most ${max}` };
    }
  }

  return null;
}

// Array validation
export function validateArray(
  value: unknown,
  field: string,
  options: { minLength?: number; maxLength?: number; required?: boolean } = {}
): ValidationError | null {
  const { minLength = 0, maxLength = 100, required = true } = options;

  if (required && (value === undefined || value === null)) {
    return { field, message: `${field} is required` };
  }

  if (value !== undefined && value !== null) {
    if (!Array.isArray(value)) {
      return { field, message: `${field} must be an array` };
    }
    if (value.length < minLength) {
      return { field, message: `${field} must have at least ${minLength} items` };
    }
    if (value.length > maxLength) {
      return { field, message: `${field} must have at most ${maxLength} items` };
    }
  }

  return null;
}

// Time validation (HH:MM format)
export function validateTime(value: unknown, field: string): ValidationError | null {
  if (value === undefined || value === null || value === '') {
    return { field, message: `${field} is required` };
  }

  if (typeof value !== 'string') {
    return { field, message: `${field} must be a string` };
  }

  const timeRegex = /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/;
  if (!timeRegex.test(value)) {
    return { field, message: `${field} must be in HH:MM format` };
  }

  return null;
}

// Validate multiple fields and return all errors
export function validateAll(validations: (ValidationError | null)[]): ValidationError[] {
  return validations.filter((v): v is ValidationError => v !== null);
}

