import { badRequest } from '../utils/httpError.js';

function checkRule(value, rule = {}) {
  if ((value === undefined || value === null || value === '') && rule.required) {
    return 'Campo obligatorio';
  }

  if (value === undefined || value === null || value === '') {
    return null;
  }

  if (rule.type === 'string' && typeof value !== 'string') {
    return 'Debe ser texto';
  }

  if (rule.type === 'number' && typeof value !== 'number') {
    return 'Debe ser numérico';
  }

  if (rule.type === 'boolean' && typeof value !== 'boolean') {
    return 'Debe ser booleano';
  }

  if (rule.enum && !rule.enum.includes(value)) {
    return 'Valor no permitido';
  }

  return null;
}

export function validateBody(rules) {
  return (req, _res, next) => {
    const errors = {};

    for (const [field, rule] of Object.entries(rules)) {
      const message = checkRule(req.body?.[field], rule);
      if (message) {
        errors[field] = message;
      }
    }

    if (Object.keys(errors).length > 0) {
      return next(badRequest('Datos de solicitud inválidos', { fields: errors }));
    }

    return next();
  };
}
