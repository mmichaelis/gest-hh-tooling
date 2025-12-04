/**
 * Date parsing utilities supporting ISO and German date formats.
 */

import { parse, isValid, format } from 'date-fns';
import { debug } from './logger.js';

/**
 * Supported date format patterns.
 */
const DATE_FORMATS = [
  'yyyy-MM-dd',     // ISO format: 2026-12-08
  'dd.MM.yyyy',     // German format: 08.12.2026
] as const;

/**
 * Parse a date string in supported formats.
 *
 * @param dateString - The date string to parse
 * @returns Parsed Date object
 * @throws Error if date cannot be parsed
 */
export function parseDate(dateString: string): Date {
  const trimmed = dateString.trim();

  for (const formatPattern of DATE_FORMATS) {
    const parsed = parse(trimmed, formatPattern, new Date());
    if (isValid(parsed)) {
      debug(`Parsed date "${trimmed}" as ${parsed.toISOString()} using format ${formatPattern}`);
      return parsed;
    }
  }

  throw new Error(`Unable to parse date: "${dateString}". Supported formats: YYYY-MM-DD or DD.MM.YYYY`);
}

/**
 * Format a Date object as ISO date string (YYYY-MM-DD).
 */
export function formatISODate(date: Date): string {
  return format(date, 'yyyy-MM-dd');
}

/**
 * Format a time string in HH:MM:SS format.
 */
export function formatTime(hours: number, minutes: number, seconds = 0): string {
  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(seconds).padStart(2, '0')}`;
}
