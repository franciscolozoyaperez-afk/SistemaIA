export class AppError extends Error {
  constructor(statusCode, message, details) {
    super(message);
    this.name = 'AppError';
    this.statusCode = statusCode;
    this.details = details;
  }
}

export function badRequest(message = 'Solicitud inválida', details) {
  return new AppError(400, message, details);
}

export function unauthorized(message = 'Autenticación requerida') {
  return new AppError(401, message);
}

export function forbidden(message = 'No tienes permisos para esta acción') {
  return new AppError(403, message);
}

export function notFound(message = 'Recurso no encontrado') {
  return new AppError(404, message);
}
