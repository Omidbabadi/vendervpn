// Idempotent provisioning for the quota backend (Node runtime).
//
//   APPWRITE_ENDPOINT=... APPWRITE_PROJECT_ID=... APPWRITE_API_KEY=... \
//     node tool/provision.mjs [--deploy path/to/code.tar.gz]
//
// Safe to re-run: existing database/tables/columns/indexes/variables are kept.
// An existing `quota` function is updated in place, so its variables
// (DEVICE_PEPPER above all) survive.
import { randomInt } from 'node:crypto';
import {
  AppwriteException,
  Client,
  Functions,
  ID,
  ProjectKeyScopes,
  Runtime,
  TablesDB,
  TablesDBIndexType,
} from 'node-appwrite';
import { InputFile } from 'node-appwrite/file';

import { Tables } from '../src/config.js';

const databaseId = 'quota';
const functionId = 'quota';
const MAX_BYTES = 9007199254740991; // 2^53-1, safe for JSON clients

const env = process.env;
for (const k of ['APPWRITE_ENDPOINT', 'APPWRITE_PROJECT_ID', 'APPWRITE_API_KEY']) {
  if (!env[k]) {
    console.error(`missing ${k}`);
    process.exit(2);
  }
}
const client = new Client()
  .setEndpoint(env.APPWRITE_ENDPOINT)
  .setProject(env.APPWRITE_PROJECT_ID)
  .setKey(env.APPWRITE_API_KEY);
const db = new TablesDB(client);
const functions = new Functions(client);

await step('database', async () => {
  if (await exists(() => db.get({ databaseId }))) return 'exists';
  await db.create({ databaseId, name: 'Quota' });
  return 'created';
});

// Server-only tables: no client permissions, the function uses its own key.
await table(Tables.subjects, 'Subjects', [varchar('type', 16), varchar('status', 16)], []);

await table(
  Tables.devices,
  'Devices',
  [varchar('subjectId', 36), varchar('platform', 16), varchar('deviceHash', 64)],
  [['idx_subject', ['subjectId']]],
);

await table(
  Tables.bindings,
  'Bindings',
  [varchar('subjectId', 36), varchar('deviceHash', 64)],
  [
    ['idx_subject', ['subjectId']],
    ['idx_device', ['deviceHash']],
  ],
);

await table(
  Tables.quotaDaily,
  'Quota daily',
  [varchar('subjectId', 36), integer('day', true), integer('usedBytes'), integer('bonusBytes')],
  [
    ['idx_subject_day', ['subjectId', 'day']],
    ['idx_day', ['day']],
  ],
);

await table(
  Tables.usageReports,
  'Usage reports',
  [varchar('subjectId', 36), integer('day', true), integer('bytes', true)],
  [['idx_created', ['$createdAt']]],
);

await table(
  Tables.bonusGrants,
  'Bonus grants',
  [varchar('subjectId', 36), integer('day', true), integer('bytes', true), varchar('source', 16)],
  [
    ['idx_subject_day', ['subjectId', 'day']],
    ['idx_created', ['$createdAt']],
  ],
);

await step('function', async () => {
  const available = (await functions.listRuntimes()).runtimes.map((r) => r.$id);
  const runtime = pickNodeRuntime(available);
  const params = {
    functionId,
    name: 'Quota',
    runtime,
    execute: ['users'], // any signed-in user, anonymous included
    schedule: '30 21 * * *', // 01:00 Asia/Tehran, cleanup job
    timeout: 15,
    entrypoint: 'src/main.js',
    commands: 'npm ci --omit=dev --no-audit --no-fund',
    scopes: [ProjectKeyScopes.RowsRead, ProjectKeyScopes.RowsWrite],
    logging: true,
  };
  if (await exists(() => functions.get({ functionId }))) {
    await functions.update(params);
    return `updated (${runtime})`;
  }
  await functions.create(params);
  return `created (${runtime})`;
});

await step('function variables', async () => {
  const existing = new Set(
    (await functions.listVariables({ functionId })).variables.map((v) => v.key),
  );
  const wanted = {
    QUOTA_DATABASE_ID: [databaseId, false],
    QUOTA_TZ: ['Asia/Tehran', false],
    FREE_BYTES: [String(500 * 1024 * 1024), false],
    MAX_REPORT_BYTES: [String(512 * 1024 * 1024), false],
    RETENTION_DAYS: ['30', false],
    BONUS_BYTES: [String(500 * 1024 * 1024), false],
    MAX_BONUSES_PER_DAY: ['5', false],
    // TEMPORARY: turn off (set to 'false' in the console) before release.
    TEST_BONUS_ENABLED: ['true', false],
    DEVICE_PEPPER: [secret(48), true], // never rotate: it keys device hashes
  };
  const added = [];
  for (const [key, [value, isSecret]] of Object.entries(wanted)) {
    if (existing.has(key)) continue;
    await functions.createVariable({
      functionId,
      variableId: ID.unique(),
      key,
      value,
      secret: isSecret,
    });
    added.push(key);
  }
  return added.length ? `added ${added.join(', ')}` : 'all present';
});

const deployIdx = process.argv.indexOf('--deploy');
if (deployIdx !== -1) {
  const path = process.argv[deployIdx + 1];
  await step('deployment', async () => {
    const d = await functions.createDeployment({
      functionId,
      code: InputFile.fromPath(path, 'code.tar.gz'),
      activate: true,
    });
    let status = d.status;
    for (let i = 0; i < 90 && status !== 'ready' && status !== 'failed'; i++) {
      await new Promise((r) => setTimeout(r, 4000));
      status = (await functions.getDeployment({ functionId, deploymentId: d.$id })).status;
    }
    if (status !== 'ready') {
      const full = await functions.getDeployment({ functionId, deploymentId: d.$id });
      console.error(String(full.buildLogs ?? '').slice(-3000));
      throw new Error(`deployment ${d.$id} is ${status}`);
    }
    return `ready (${d.$id})`;
  });
}

// ------------------------------------------------------------------ helpers

function pickNodeRuntime(available) {
  // Newest Node runtime the server offers that this SDK also knows.
  const known = new Set(Object.values(Runtime));
  const ver = (id) => {
    const [maj, min = 0] = id.slice(5).split('.').map(Number);
    return maj * 100 + min;
  };
  const candidates = available
    .filter((id) => id.startsWith('node-') && known.has(id))
    .sort((a, b) => ver(b) - ver(a));
  if (!candidates.length) throw new Error(`No Node runtime enabled: ${available}`);
  return candidates[0];
}

function secret(length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  return Array.from({ length }, () => chars[randomInt(chars.length)]).join('');
}

function varchar(key, size) {
  return [key, (tableId) => db.createVarcharColumn({ databaseId, tableId, key, size, required: true })];
}

function integer(key, required = false) {
  return [
    key,
    (tableId) =>
      db.createIntegerColumn({
        databaseId,
        tableId,
        key,
        required,
        min: 0,
        max: MAX_BYTES,
        xdefault: required ? null : 0,
      }),
  ];
}

async function table(tableId, name, columns, indexes) {
  await step(`table ${tableId}`, async () => {
    if (!(await exists(() => db.getTable({ databaseId, tableId })))) {
      await db.createTable({ databaseId, tableId, name, permissions: [], rowSecurity: false });
    }
    const have = new Set((await db.listColumns({ databaseId, tableId })).columns.map((c) => c.key));
    const added = [];
    for (const [key, create] of columns) {
      if (have.has(key)) continue;
      await create(tableId);
      added.push(key);
    }
    await waitColumns(tableId);
    const haveIdx = new Set((await db.listIndexes({ databaseId, tableId })).indexes.map((i) => i.key));
    for (const [key, cols] of indexes) {
      if (haveIdx.has(key)) continue;
      try {
        await db.createIndex({ databaseId, tableId, key, type: TablesDBIndexType.Key, columns: cols });
        added.push(`index:${key}`);
      } catch (e) {
        console.log(`    ! index ${key} skipped: ${e.message}`);
      }
    }
    return added.length ? `added ${added.join(', ')}` : 'up to date';
  });
}

async function waitColumns(tableId) {
  for (let i = 0; i < 60; i++) {
    const statuses = (await db.listColumns({ databaseId, tableId })).columns.map((c) => String(c.status));
    if (statuses.every((s) => s.endsWith('available'))) return;
    if (statuses.some((s) => s.endsWith('failed'))) {
      throw new Error(`column creation failed in ${tableId}: ${statuses}`);
    }
    await new Promise((r) => setTimeout(r, 1000));
  }
  throw new Error(`columns in ${tableId} not available after 60s`);
}

async function exists(get) {
  try {
    await get();
    return true;
  } catch (e) {
    if (e instanceof AppwriteException && e.code === 404) return false;
    throw e;
  }
}

async function step(name, run) {
  try {
    const r = await run();
    console.log(`✓ ${name}${typeof r === 'string' ? `: ${r}` : ''}`);
  } catch (e) {
    const detail = e instanceof AppwriteException ? `${e.code} ${e.type} ${e.message}` : e.message;
    console.log(`✗ ${name}: ${detail}`);
    process.exit(1);
  }
}
