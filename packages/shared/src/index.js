export const APP_NAME = 'SIGSE-CETIS 61';
export const APP_DESCRIPTION = 'Sistema Integral de Gestión y Seguimiento Estudiantil';

export const ROLES = Object.freeze({
  ADMIN: 'admin',
  STAFF: 'staff',
  TEACHER: 'teacher',
  GUARDIAN: 'guardian',
  STUDENT: 'student'
});

export const MODULES = Object.freeze([
  {
    id: 'dashboard',
    label: 'Panel principal',
    path: '/dashboard',
    description: 'Indicadores y resumen operativo.',
    icon: 'dashboard'
  },
  {
    id: 'students',
    label: 'Estudiantes',
    path: '/dashboard/estudiantes',
    description: 'Administración de la matrícula estudiantil.',
    icon: 'students'
  },
  {
    id: 'access',
    label: 'Control de acceso',
    path: '/dashboard/accesos',
    description: 'Entradas, salidas y movimientos institucionales.',
    icon: 'access'
  },
  {
    id: 'incidents',
    label: 'Incidencias',
    path: '/dashboard/incidencias',
    description: 'Seguimiento de casos y acciones correctivas.',
    icon: 'incidents'
  },
  {
    id: 'guardians',
    label: 'Padres y tutores',
    path: '/dashboard/tutores',
    description: 'Contacto y relación con estudiantes.',
    icon: 'guardians'
  },
  {
    id: 'notifications',
    label: 'Notificaciones',
    path: '/dashboard/notificaciones',
    description: 'Comunicados y alertas para la comunidad.',
    icon: 'notifications'
  },
  {
    id: 'reports',
    label: 'Reportes',
    path: '/dashboard/reportes',
    description: 'Estadísticas y reportes institucionales.',
    icon: 'reports'
  },
  {
    id: 'users',
    label: 'Usuarios y roles',
    path: '/dashboard/usuarios',
    description: 'Administración de accesos y permisos.',
    icon: 'users'
  }
]);

export const API_ENDPOINTS = Object.freeze({
  HEALTH: '/health',
  STATUS: '/v1/status'
});

export const DEMO_DATA_NOTICE = 'Datos de demostración: no representan información real de estudiantes.';
