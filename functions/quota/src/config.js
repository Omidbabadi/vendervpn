/**
 * Function settings, read from Appwrite function variables so limits can
 * change without an app release.
 */
export function loadConfig(env = process.env) {
  const intOf = (key, fallback) => {
    const n = Number.parseInt(env[key] ?? '', 10);
    return Number.isSafeInteger(n) ? n : fallback;
  };
  const pepper = env.DEVICE_PEPPER ?? '';
  if (pepper.length < 16) {
    throw new Error('DEVICE_PEPPER is missing or too short');
  }
  return Object.freeze({
    endpoint: env.APPWRITE_FUNCTION_API_ENDPOINT ?? '',
    projectId: env.APPWRITE_FUNCTION_PROJECT_ID ?? '',
    databaseId: env.QUOTA_DATABASE_ID ?? 'quota',
    timezone: env.QUOTA_TZ ?? 'Asia/Tehran',
    freeBytes: intOf('FREE_BYTES', 500 * 1024 * 1024),
    // Upper bound for one /report call. The app reports every few minutes,
    // so anything bigger is a bug or abuse.
    maxReportBytes: intOf('MAX_REPORT_BYTES', 512 * 1024 * 1024),
    devicePepper: pepper,
    retentionDays: intOf('RETENTION_DAYS', 30),
    // Rewarded-ad bonus. The amount is decided here, never by the app.
    bonusBytes: intOf('BONUS_BYTES', 500 * 1024 * 1024),
    maxBonusesPerDay: intOf('MAX_BONUSES_PER_DAY', 5),
    // TEMPORARY: /bonus grants without ad verification, for testing only.
    // Set to 'false' before release; real grants will come from AdMob SSV.
    testBonusEnabled: (env.TEST_BONUS_ENABLED ?? '') === 'true',
  });
}

/** Table IDs, shared with the provisioning script. */
export const Tables = Object.freeze({
  subjects: 'subjects',
  devices: 'devices',
  bindings: 'bindings',
  quotaDaily: 'quota_daily',
  usageReports: 'usage_reports',
  bonusGrants: 'bonus_grants',
});
