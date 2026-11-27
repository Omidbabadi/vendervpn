import assert from 'node:assert/strict';
import { test } from 'node:test';

import { QuotaClock } from '../src/quotaDay.js';

const at = (iso) => new QuotaClock('Asia/Tehran', () => new Date(iso));

test('day rolls over at Tehran midnight, not UTC midnight', () => {
  // 20:29:59Z = 23:59:59 in Tehran (+03:30).
  const before = at('2026-11-25T20:29:59Z').today();
  assert.equal(before.key, 20261125);
  assert.equal(before.iso, '2026-11-25');
  assert.equal(before.resetsAt.toISOString(), '2026-11-25T20:30:00.000Z');

  const after = at('2026-11-25T20:30:00Z').today();
  assert.equal(after.key, 20261126);
  assert.equal(after.iso, '2026-11-26');
  assert.equal(after.resetsAt.toISOString(), '2026-11-26T20:30:00.000Z');
});

test('UTC date can differ from the quota day', () => {
  // 22:00Z on Nov 26 is already Nov 27 in Tehran.
  assert.equal(at('2026-11-26T22:00:00Z').today().iso, '2026-11-27');
});

test('month and year boundaries', () => {
  const nye = at('2026-12-31T21:00:00Z').today();
  assert.equal(nye.iso, '2027-01-01');
  assert.equal(nye.resetsAt.toISOString(), '2027-01-01T20:30:00.000Z');
  assert.equal(at('2026-11-30T20:45:00Z').today().iso, '2026-12-01');
});

test('keyDaysAgo', () => {
  assert.equal(at('2026-11-26T08:00:00Z').keyDaysAgo(30), 20261027);
});

test('unknown timezone throws', () => {
  assert.throws(() => new QuotaClock('Mars/Olympus'));
});
