import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { env } from './config/env.js';
import { apiRateLimiter } from './middlewares/rateLimiter.js';
import { requestLogger } from './middlewares/requestLogger.js';
import { errorHandler, notFoundHandler } from './middlewares/errorHandler.js';
import { forbidden } from './utils/httpError.js';
import apiRouter from './routes/index.js';

const app = express();

app.disable('x-powered-by');
app.set('trust proxy', 1);

app.use(helmet());
app.use(cors({
  origin(origin, callback) {
    if (!origin) {
      return callback(null, true);
    }

    const localhostAllowed = !env.isProduction && /^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin);

    if (env.corsOrigins.includes(origin) || localhostAllowed) {
      return callback(null, true);
    }

    return callback(forbidden('Origen no permitido por CORS'));
  },
  credentials: true
}));
app.use(express.json({ limit: '100kb' }));
app.use(requestLogger);
app.use(apiRateLimiter);

app.use('/api', apiRouter);
app.use('/', apiRouter);

app.use(notFoundHandler);
app.use(errorHandler);

if (!process.env.VERCEL) {
  app.listen(env.port, () => {
    console.log(`SIGSE-CETIS 61 API escuchando en http://localhost:${env.port}`);
  });
}

export default app;
