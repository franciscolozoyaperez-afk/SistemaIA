import { Router } from 'express';
import { getHealth, getStatus } from '../controllers/healthController.js';

const router = Router();

router.get('/', getStatus);
router.get('/health', getHealth);
router.get('/v1/status', getStatus);

export default router;
