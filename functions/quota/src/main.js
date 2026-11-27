import { AppwriteException, Client, TablesDB } from 'node-appwrite';

import { loadConfig } from './config.js';
import { QuotaClock } from './quotaDay.js';
import { ApiError, QuotaService } from './quotaService.js';

/**
 * Appwrite function entrypoint.
 *
 * Routes (all need a signed-in user; anonymous is fine):
 *   POST /bind    {platform: android|ios, deviceId}
 *   GET  /quota
 *   POST /report  {reportId, bytes}
 *   POST /bonus   {grantId}   TEMPORARY, only with TEST_BONUS_ENABLED=true
 * A scheduled execution runs the cleanup job instead.
 */
export default async ({ req, res, error }) => {
  const headers = Object.fromEntries(
    Object.entries(req.headers ?? {}).map(([k, v]) => [k.toLowerCase(), String(v)]),
  );

  let config;
  let clock;
  try {
    config = loadConfig();
    clock = new QuotaClock(config.timezone);
  } catch (e) {
    error(`Bad function config: ${e.message}`);
    return res.json({ error: 'server_misconfigured' }, 500);
  }

  const client = new Client()
    .setEndpoint(config.endpoint)
    .setProject(config.projectId)
    // Dynamic per-execution key, limited to the function's scopes.
    .setKey(headers['x-appwrite-key'] ?? process.env.APPWRITE_API_KEY ?? '');
  const service = new QuotaService(new TablesDB(client), config, clock);

  try {
    if (headers['x-appwrite-trigger'] === 'schedule') {
      return res.json(await service.cleanup(), 200);
    }

    const userId = headers['x-appwrite-user-id'] ?? '';
    if (!userId) throw new ApiError(401, 'unauthenticated');

    const route = `${String(req.method).toUpperCase()} ${req.path}`;
    let result;
    switch (route) {
      case 'POST /bind':
        result = await service.bind(userId, parseBody(req));
        break;
      case 'GET /quota':
        result = await service.getQuota(userId);
        break;
      case 'POST /report':
        result = await service.report(userId, parseBody(req));
        break;
      case 'POST /bonus': // TEMPORARY test grant, see QuotaService.grantTestBonus
        result = await service.grantTestBonus(userId, parseBody(req));
        break;
      default:
        throw new ApiError(404, 'not_found');
    }
    return res.json(result, 200);
  } catch (e) {
    if (e instanceof ApiError) {
      return res.json({ error: e.code, ...(e.detail ? { message: e.detail } : {}) }, e.status);
    }
    if (e instanceof AppwriteException) {
      error(`Appwrite error ${e.code} ${e.type}: ${e.message}`);
      return res.json({ error: 'backend_error' }, 500);
    }
    error(`Unexpected: ${e?.stack ?? e}`);
    return res.json({ error: 'internal' }, 500);
  }
};

function parseBody(req) {
  const text = typeof req.bodyText === 'string' ? req.bodyText : String(req.bodyRaw ?? '');
  if (!text.trim()) return {};
  try {
    const decoded = JSON.parse(text);
    if (decoded && typeof decoded === 'object' && !Array.isArray(decoded)) return decoded;
  } catch {
    // fall through
  }
  throw new ApiError(400, 'invalid_json');
}
