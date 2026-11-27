/**
 * Works out "today" on the server clock in a fixed IANA timezone
 * (Asia/Tehran). Uses the runtime's ICU tz data instead of a hardcoded
 * +03:30, so a future DST change only needs a runtime update.
 *
 * A quota day is { key, iso, resetsAt }:
 *   key      yyyyMMdd as a number (e.g. 20261126), sortable and cheap to index
 *   iso      'yyyy-MM-dd', what the app shows and caches
 *   resetsAt Date (UTC instant) when this day ends and the quota resets
 */
export class QuotaClock {
  constructor(timezone, now = () => new Date()) {
    this.timezone = timezone;
    this.now = now;
    // Throws RangeError on an unknown timezone, which surfaces as bad config.
    this.fmt = new Intl.DateTimeFormat('en-US', {
      timeZone: timezone,
      hourCycle: 'h23',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
    });
  }

  today() {
    return this.dayOf(this.now());
  }

  dayOf(instant) {
    const p = this.#parts(instant);
    const next = new Date(Date.UTC(p.year, p.month - 1, p.day + 1));
    const pad = (n) => String(n).padStart(2, '0');
    return {
      key: p.year * 10000 + p.month * 100 + p.day,
      iso: `${p.year}-${pad(p.month)}-${pad(p.day)}`,
      resetsAt: new Date(
        this.#localMidnightUtc(next.getUTCFullYear(), next.getUTCMonth() + 1, next.getUTCDate()),
      ),
    };
  }

  /** Day key `days` before today, used by the cleanup job. */
  keyDaysAgo(days) {
    return this.dayOf(new Date(this.now().getTime() - days * 86_400_000)).key;
  }

  #parts(instant) {
    const out = {};
    for (const { type, value } of this.fmt.formatToParts(instant)) {
      if (type !== 'literal') out[type] = Number(value);
    }
    return out;
  }

  /** Local-minus-UTC offset in ms at `instant`. */
  #offsetMs(ms) {
    const p = this.#parts(new Date(ms));
    const asUtc = Date.UTC(p.year, p.month - 1, p.day, p.hour, p.minute, p.second);
    return asUtc - Math.floor(ms / 1000) * 1000;
  }

  #localMidnightUtc(year, month, day) {
    const guess = Date.UTC(year, month - 1, day);
    let t = guess - this.#offsetMs(guess);
    // Second pass handles an offset change between the guess and the answer.
    const corrected = guess - this.#offsetMs(t);
    if (corrected !== t) t = corrected;
    return t;
  }
}
