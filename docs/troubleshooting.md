# Solución de problemas

## npm install muy lento o timeouts

El registro npm puede responder lentamente en algunas redes. Si `npm install` se queda esperando, cancelar y reintentar con:

```bash
npm install --no-audit --no-fund --fetch-retries=5 --fetch-retry-mintimeout=15000 --fetch-retry-maxtimeout=120000 --fetch-timeout=600000
```

Si el `package-lock.json` reporta daño o el árbol de `node_modules` queda mezclado entre raíz y workspaces, regenerarlo:

```bash
rm -f package-lock.json
rm -rf node_modules apps/frontend/node_modules apps/backend/node_modules
npm install
```

## esbuild 0.28.x provoca SIGSEGV

En el entorno local se observó que `esbuild@0.28.2` hacía fallar su binario con `SIGSEGV`. El `package.json` raíz fija `overrides.esbuild` a `0.27.7`, versión compatible con Vite 7 y estable en este equipo.

Si una actualización futura de Vite requiere otra línea de esbuild, validar primero que `node_modules/esbuild/bin/esbuild --version` responda correctamente.

## Binarios nativos corruptos de Rollup

Si `vite build` termina con `Bus error (core dumped)` y `rollup.linux-x64-gnu.node` aparece truncado o con `missing section headers`, reinstalar el paquete opcional:

```bash
rm -rf node_modules
npm install
```

Si persiste, limpiar caché de npm y reinstalar.

## Frontend no conecta con el API

1. Verificar que el backend esté en `http://localhost:3001`.
2. Comprobar `curl http://localhost:3001/api/health`.
3. Comprobar `curl http://localhost:5173/api/health` para validar el proxy de Vite.
4. En producción, definir `PUBLIC_API_BASE_URL` con la URL pública del backend y agregar el dominio del frontend a `API_CORS_ORIGINS`.

## Login no funciona

1. Verificar `apps/frontend/.env.local` con `PUBLIC_SUPABASE_URL` y `PUBLIC_SUPABASE_ANON_KEY`.
2. Confirmar que la URL de Supabase sea la del proyecto correcto.
3. Confirmar que el usuario exista en Supabase Auth.
4. Revisar que la migración de `profiles` se haya aplicado si se requiere rol/perfil.
