const sanitizeHtml = require('sanitize-html');
const functions = require('firebase-functions');
const admin = require("firebase-admin");

/**
 * Sanitize user input: strip HTML, trim, and optionally limit length.
 * 
 * @param {string} input - The user input string
 * @param {number} [maxLength] - Optional maximum length
 * @returns {string} The cleaned input
 * @throws {functions.https.HttpsError} If maxLength is provided and exceeded
 */
function sanitizeString(input, maxLength) {
  if (typeof input !== 'string') {
    throw new functions.https.HttpsError('invalid-argument', 'Input must be a string.');
  }

  const cleaned = sanitizeHtml(input, {
    allowedTags: [],
    allowedAttributes: {}
  }).trim();

  if (maxLength && cleaned.length > maxLength) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      `Input exceeds maximum length of ${maxLength} characters.`
    );
  }

  return cleaned;
}

function doesAppointmentMatchSlot(startDate, endDate, scheduleRules, sessionDuration, timezoneOffset) {
  const weekDay = startDate.getDay().toString();

  const appointmentStart = startDate.getHours() * 60 + startDate.getMinutes();
  const appointmentEnd = endDate.getHours() * 60 + endDate.getMinutes();

  const periods = scheduleRules[weekDay];
  if (!Array.isArray(periods)) return false;

  const matchesAny = periods.some(period => {
    const [periodStartStr, periodEndStr] = period.split("-");
    const periodStart = parseInt(periodStartStr, 10) - timezoneOffset;
    const periodEnd = parseInt(periodEndStr, 10) - timezoneOffset;

    if (appointmentStart < periodStart || appointmentEnd > periodEnd) return false;

    const offsetFromPeriodStart = appointmentStart - periodStart;
    if (offsetFromPeriodStart % sessionDuration !== 0) return false;

    if (appointmentEnd - appointmentStart !== sessionDuration) return false;

    return true;
  });

  return matchesAny;
}

function isWorkPeriodValid(periods) {
  if (!Array.isArray(periods)) return false;

  const timeRanges = [];

  for (const str of periods) {
    if (typeof str !== 'string') return false;

    // Match 1 to 4 digit numbers for start and end minutes, separated by '-'
    const match = str.match(/^(\d{1,4})-(\d{1,4})$/);
    if (!match) return false;

    const start = parseInt(match[1], 10);
    const end = parseInt(match[2], 10);

    // Validate minutes are within 0 and 1440 (24h * 60)
    if (start < 0 || start >= 1440 || end < 0 || end > 1440) return false;

    if (start >= end) return false;

    timeRanges.push([start, end]);
  }

  // Sort ranges by start time
  timeRanges.sort((a, b) => a[0] - b[0]);

  // Check for overlapping periods
  for (let i = 1; i < timeRanges.length; i++) {
    const [prevStart, prevEnd] = timeRanges[i - 1];
    const [currStart, currEnd] = timeRanges[i];

    if (currStart < prevEnd) return false;
  }

  return true;
}

function isRuleSameDayAsDate(rule, timestamp) {
  // 1. Check range mode
  if (rule.range?.start && rule.range?.end) {
    return rule.range.start < timestamp.seconds && timestamp.seconds < rule.range.end;
  }

  // 2. Check selected days
  const isSameDay = (a, b) =>
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate();

  const isContained = rule.days.some((day) => {
    const ruleDate = new admin.firestore.Timestamp(day, 0).toDate();
    return isSameDay(ruleDate, timestamp.toDate());
  });

  return isContained;
}

function doesRuleCoverPeriod(rule, startDate, endDate, timezoneOffset) {
  const start = startDate.getHours() * 60 + startDate.getMinutes();
  const end = endDate.getHours() * 60 + endDate.getMinutes();

  // 3. If no work periods, the day is covered
  if (!rule.periods || rule.periods.length === 0) {
    return true;
  }

  // 4. Check if time is within any work period
  const matchesAnyPeriod = rule.periods.some((period) => {
    const [periodStartStr, periodEndStr] = period.split("-");
    const periodStart = parseInt(periodStartStr, 10) - timezoneOffset;
    const periodEnd = parseInt(periodEndStr, 10) - timezoneOffset;

    return periodStart <= start && end <= periodEnd;
  });

  return matchesAnyPeriod;
}

exports.sanitizeString = sanitizeString;
exports.doesAppointmentMatchSlot = doesAppointmentMatchSlot;
exports.isWorkPeriodValid = isWorkPeriodValid;
exports.isRuleSameDayAsDate = isRuleSameDayAsDate;
exports.doesRuleCoverPeriod = doesRuleCoverPeriod;
