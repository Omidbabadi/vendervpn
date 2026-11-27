import { createHash } from 'node:crypto';
import { AppwriteException, ID, Query } from 'node-appwrite';

import { Tables } from './config.js';

/** An error that maps to an HTTP response for the app. */
export class ApiError extends Error {
  constructor(status, code, message = '') {
    super(message || code);
    this.status = status;
    this.code = code;
    this.detail = message;
  }
}

const PLATFORMS = new Set(['android', 'ios']);
const ID_PATTERN = /^[A-Za-z0-9][A-Za-z0-9._-]{7,35}$/;

const isCode = (e, code) => e instanceof AppwriteException && e.code === code;

/**
 * Quota logic. Every quota belongs to a *subject* (a device today, an account
 * later), never to the anonymous Appwrite user directly: a reinstall creates a
 * new anonymous user, but the device resolves to the same subject.
 */
export class QuotaService {
  /**
   * @param {import('node-appwrite').TablesDB} db
   * @param {ReturnType<import('./config.js').loadConfig>} config
   * @param {import('./quotaDay.js').QuotaClock} clock
   */
  constructor(db, config, clock) {
    this.db = db;
    this.config = config;
    this.clock = clock;
    this.dbId = config.databaseId;
  }

  // ---------------------------------------------------------------- bind

  /** Links the calling anonymous user to the subject of its device. */
  async bind(userId, body) {
    const { platform, deviceId } = body;
    if (typeof platform !== 'string' || !PLATFORMS.has(platform)) {
      throw new ApiError(400, 'invalid_platform');
    }
    if (typeof deviceId !== 'string' || deviceId.length < 8 || deviceId.length > 128) {
      throw new ApiError(400, 'invalid_device_id');
    }
    const deviceHash = this.#hashDevice(platform, deviceId);

    const existing = await this.#getRow(Tables.bindings, userId);
    if (existing) {
      if (existing.deviceHash !== deviceHash) {
        throw new ApiError(409, 'already_bound_to_other_device');
      }
      return { subjectId: existing.subjectId, bound: true };
    }

    const subjectId = await this.#subjectForDevice(deviceHash, platform);
    try {
      await this.db.createRow({
        databaseId: this.dbId,
        tableId: Tables.bindings,
        rowId: userId,
        data: { subjectId, deviceHash },
      });
    } catch (e) {
      if (!isCode(e, 409)) throw e; // concurrent bind from the same user
    }
    return { subjectId, bound: true };
  }

  async #subjectForDevice(deviceHash, platform) {
    const rowId = deviceHash.slice(0, 32);
    const device = await this.#getRow(Tables.devices, rowId);
    if (device) return device.subjectId;

    const subject = await this.db.createRow({
      databaseId: this.dbId,
      tableId: Tables.subjects,
      rowId: ID.unique(),
      data: { type: 'device', status: 'active' },
    });
    try {
      await this.db.createRow({
        databaseId: this.dbId,
        tableId: Tables.devices,
        rowId,
        data: { subjectId: subject.$id, platform, deviceHash },
      });
      return subject.$id;
    } catch (e) {
      if (!isCode(e, 409)) throw e;
      // Another install of the same device won the race: use its subject.
      await this.#deleteQuietly(Tables.subjects, subject.$id);
      const winner = await this.#getRow(Tables.devices, rowId);
      return winner.subjectId;
    }
  }

  #hashDevice(platform, deviceId) {
    return createHash('sha256')
      .update(`${this.config.devicePepper}:${platform}:${deviceId}`, 'utf8')
      .digest('hex');
  }

  // ---------------------------------------------------------------- quota

  async getQuota(userId) {
    const subjectId = await this.#subjectOf(userId);
    const day = this.clock.today();
    const row = await this.#getRow(Tables.quotaDaily, quotaRowId(subjectId, day));
    return this.#view(day, row);
  }

  /**
   * Adds `bytes` to today's usage. `reportId` makes retries safe: the same
   * report is only ever counted once.
   */
  async report(userId, body) {
    const { reportId, bytes } = body;
    const max = this.config.maxReportBytes;
    if (typeof reportId !== 'string' || !ID_PATTERN.test(reportId)) {
      throw new ApiError(400, 'invalid_report_id');
    }
    if (!Number.isSafeInteger(bytes) || bytes <= 0 || bytes > max) {
      throw new ApiError(400, 'invalid_bytes', `bytes must be 1..${max}`);
    }

    const subjectId = await this.#subjectOf(userId);
    const day = this.clock.today();
    const rowId = quotaRowId(subjectId, day);

    try {
      await this.db.createRow({
        databaseId: this.dbId,
        tableId: Tables.usageReports,
        rowId: reportId,
        data: { subjectId, day: day.key, bytes },
      });
    } catch (e) {
      if (!isCode(e, 409)) throw e;
      const row = await this.#getRow(Tables.quotaDaily, rowId);
      return { ...this.#view(day, row), duplicate: true };
    }

    try {
      const row = await this.#addUsage(subjectId, day, rowId, bytes);
      return this.#view(day, row);
    } catch (e) {
      // Let the app retry the same reportId instead of losing the bytes.
      await this.#deleteQuietly(Tables.usageReports, reportId);
      throw e;
    }
  }

  /**
   * TEMPORARY test grant of the rewarded-ad bonus, with no ad verification.
   * Only enabled while TEST_BONUS_ENABLED=true; the real path will be an
   * AdMob server-side verification callback. The amount comes from config,
   * never from the app. `grantId` makes retries safe.
   */
  async grantTestBonus(userId, body) {
    if (!this.config.testBonusEnabled) throw new ApiError(403, 'bonus_disabled');
    const { grantId } = body;
    if (typeof grantId !== 'string' || !ID_PATTERN.test(grantId)) {
      throw new ApiError(400, 'invalid_grant_id');
    }

    const subjectId = await this.#subjectOf(userId);
    const day = this.clock.today();
    const rowId = quotaRowId(subjectId, day);
    const bonus = this.config.bonusBytes;

    const current = await this.#getRow(Tables.quotaDaily, rowId);
    const granted = Math.trunc(Number(current?.bonusBytes ?? 0));
    if (granted >= bonus * this.config.maxBonusesPerDay) {
      throw new ApiError(429, 'bonus_limit_reached');
    }

    try {
      await this.db.createRow({
        databaseId: this.dbId,
        tableId: Tables.bonusGrants,
        rowId: grantId,
        data: { subjectId, day: day.key, bytes: bonus, source: 'test' },
      });
    } catch (e) {
      if (!isCode(e, 409)) throw e;
      return { ...this.#view(day, current), duplicate: true };
    }

    try {
      const row = await this.#increment(subjectId, day, rowId, 'bonusBytes', bonus);
      return { ...this.#view(day, row), grantedBytes: bonus };
    } catch (e) {
      await this.#deleteQuietly(Tables.bonusGrants, grantId);
      throw e;
    }
  }

  #addUsage(subjectId, day, rowId, bytes) {
    return this.#increment(subjectId, day, rowId, 'usedBytes', bytes);
  }

  /** Atomic increment; creates today's row on first use. Never read-then-write. */
  async #increment(subjectId, day, rowId, column, value) {
    const increment = () =>
      this.db.incrementRowColumn({
        databaseId: this.dbId,
        tableId: Tables.quotaDaily,
        rowId,
        column,
        value,
      });

    try {
      return await increment();
    } catch (e) {
      if (!isCode(e, 404)) throw e;
    }
    try {
      const data = { subjectId, day: day.key, usedBytes: 0, bonusBytes: 0 };
      data[column] = value;
      return await this.db.createRow({
        databaseId: this.dbId,
        tableId: Tables.quotaDaily,
        rowId,
        data,
      });
    } catch (e) {
      if (!isCode(e, 409)) throw e;
      return increment(); // another request created it first
    }
  }

  #view(day, row) {
    const used = Math.trunc(Number(row?.usedBytes ?? 0));
    const bonus = Math.trunc(Number(row?.bonusBytes ?? 0));
    const limit = this.config.freeBytes + bonus;
    const perAd = this.config.bonusBytes;
    const maxBonuses = this.config.maxBonusesPerDay;
    // Same rule /bonus enforces: a grant is allowed while bonus < perAd * max.
    const bonusesLeft =
      perAd > 0 ? Math.max(0, Math.ceil((perAd * maxBonuses - bonus) / perAd)) : 0;
    return {
      day: day.iso,
      usedBytes: used,
      bonusBytes: bonus,
      freeBytes: this.config.freeBytes,
      bonusPerAdBytes: perAd,
      maxBonusesPerDay: maxBonuses,
      bonusesLeftToday: bonusesLeft,
      limitBytes: limit,
      remainingBytes: Math.max(0, limit - used),
      resetsAt: day.resetsAt.toISOString(),
      serverTime: new Date().toISOString(),
    };
  }

  // ---------------------------------------------------------------- cleanup

  /** Scheduled run: keeps table sizes bounded. */
  async cleanup() {
    await this.db.deleteRows({
      databaseId: this.dbId,
      tableId: Tables.quotaDaily,
      queries: [Query.lessThan('day', this.clock.keyDaysAgo(this.config.retentionDays))],
    });
    const cutoff = new Date(Date.now() - 48 * 3_600_000);
    await this.db.deleteRows({
      databaseId: this.dbId,
      tableId: Tables.usageReports,
      queries: [Query.lessThan('$createdAt', cutoff.toISOString())],
    });
    await this.db.deleteRows({
      databaseId: this.dbId,
      tableId: Tables.bonusGrants,
      queries: [Query.lessThan('$createdAt', cutoff.toISOString())],
    });
    return { ok: true };
  }

  // ---------------------------------------------------------------- helpers

  async #subjectOf(userId) {
    const binding = await this.#getRow(Tables.bindings, userId);
    if (!binding) throw new ApiError(412, 'not_bound');
    return binding.subjectId;
  }

  async #getRow(tableId, rowId) {
    try {
      return await this.db.getRow({ databaseId: this.dbId, tableId, rowId });
    } catch (e) {
      if (isCode(e, 404)) return null;
      throw e;
    }
  }

  async #deleteQuietly(tableId, rowId) {
    try {
      await this.db.deleteRow({ databaseId: this.dbId, tableId, rowId });
    } catch {
      // best effort
    }
  }
}

/**
 * Deterministic row ID: every lookup is a direct get, no index scan, and
 * there can never be two rows for the same subject and day.
 */
export const quotaRowId = (subjectId, day) => `${subjectId}_${day.key}`;
