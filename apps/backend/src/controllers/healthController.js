import { asyncHandler } from '../utils/asyncHandler.js';
import { sendSuccess } from '../utils/response.js';
import { getSystemStatus } from '../services/systemService.js';

export const getHealth = asyncHandler(async (_req, res) => {
  sendSuccess(res, {
    status: 'ok',
    service: 'sigse-cetis61-api',
    timestamp: new Date().toISOString()
  });
});

export const getStatus = asyncHandler(async (_req, res) => {
  sendSuccess(res, getSystemStatus());
});
