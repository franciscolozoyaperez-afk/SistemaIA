export function requestLogger(req, _res, next) {
  const startedAt = process.hrtime.bigint();

  _res.on('finish', () => {
    const durationMs = Number(process.hrtime.bigint() - startedAt) / 1_000_000;
    console.info(JSON.stringify({
      type: 'http_request',
      method: req.method,
      path: req.originalUrl.split('?')[0],
      statusCode: _res.statusCode,
      durationMs: Math.round(durationMs)
    }));
  });

  next();
}
