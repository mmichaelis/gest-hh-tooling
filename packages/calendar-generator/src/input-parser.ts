/**
 * Input file parser for date lists.
 */

import type { ParsedInputLine } from './types.js';
import { debug } from './logger.js';

/**
 * Parse input file content into structured lines.
 *
 * Supports two formats:
 * 1. Simple dates: "12.01.2026" or "2026-01-12"
 * 2. Event type with date: "GEST-Sitzung,12.01.2026"
 */
export function parseInputLines(content: string): ParsedInputLine[] {
  const lines = content.split('\n');
  const result: ParsedInputLine[] = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]?.trim() ?? '';
    const lineNumber = i + 1;

    // Skip empty lines and comments
    if (line.length === 0 || line.startsWith('#')) {
      continue;
    }

    // Check if line contains event type
    if (line.includes(',')) {
      const parts = line.split(',').map((p) => p.trim());
      if (parts.length === 2) {
        const [eventType, dateString] = parts;
        if (eventType !== undefined && eventType.length > 0 &&
            dateString !== undefined && dateString.length > 0) {
          result.push({ eventType, dateString, lineNumber });
          debug(`Parsed line ${String(lineNumber)}: eventType="${eventType}", date="${dateString}"`);
          continue;
        }
      }
    }

    // Treat as simple date
    result.push({ dateString: line, lineNumber });
    debug(`Parsed line ${String(lineNumber)}: date="${line}"`);
  }

  return result;
}
