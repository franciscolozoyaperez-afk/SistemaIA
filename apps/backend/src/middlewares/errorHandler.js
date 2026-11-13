import { AppError } from '../utils/httpError.js';
import { env } from '../config/env.js';

export function notFoundHandler(_req, res) {
  return res.status(404).json({
    success: false,
    error: {
      message: 'Ruta no encontrada'
    }
  });
}

export function errorHandler(error, _req, res, _next) {
  const statusCode = error.statusCode || error.status || 500;
  const message = error instanceof AppError || statusCode < 500
    ? error.message
    : 'Error interno del servidor';

  if (statusCode >= 500) {
    console.error(JSON.stringify({
      type: 'http_error',
      message: error.message,
      stack: env.isProduction ? undefined : error.stack
    }));
  }

  return res.status(statusCode).json({
    success: false,
    error: {
      message,
      ...(error.details ? { details: error.details } : {})
    }
  });
}
