/**
 * CSV formatting and output utilities.
 */

import { stringify } from 'csv-stringify/sync';
import type { CsvOutputOptions, LinkValidationResult } from './types.js';

/**
 * BOM (Byte Order Mark) to help Excel determine UTF-8 encoding.
 */
const BOM = '\uFEFF';

/**
 * Convert link validation results to CSV format.
 */
export function resultsToCsv(
  results: readonly LinkValidationResult[],
  options: CsvOutputOptions
): string {
  const records = [
    ['URL', 'Status', 'Effective URL', 'Title'],
    ...results.map((result) => [
      result.url,
      String(result.statusCode),
      result.effectiveUrl,
      result.title,
    ]),
  ];

  const csv = stringify(records, {
    delimiter: options.delimiter,
    quote: options.quote,
    quoted: true,
    // eslint-disable-next-line camelcase
    quoted_empty: true,
  });

  return options.includeBom ? BOM + csv : csv;
}
