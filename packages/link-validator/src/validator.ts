/**
 * Main validator module that orchestrates the link validation process.
 */

import { extractLinksFromTable, validateLink } from './http-client.js';
import { info } from './logger.js';
import type { LinkValidationResult, ValidatorConfig } from './types.js';

/**
 * Default configuration for the Stadtteilschulen validator.
 */
export const DEFAULT_CONFIG: ValidatorConfig = {
  url: 'https://gest-hamburg.de/stadtteilschulen/',
  tableId: 'tablepress-stadtteilschulen',
  userAgent: 'Mozilla/5.0 (compatible; GESTBot/1.0; +https://gest-hamburg.de/)',
  csvDelimiter: ';',
  csvQuote: '"',
} as const;

/**
 * Validate all links from the configured source.
 */
export async function validateLinks(
  config: ValidatorConfig = DEFAULT_CONFIG
): Promise<LinkValidationResult[]> {
  // Extract links from the source
  const links = await extractLinksFromTable(config);
  info(`Validating ${links.length} links...`);

  // Validate each link
  const results: LinkValidationResult[] = [];

  for (const url of links) {
    const validation = await validateLink(url, config.userAgent);
    results.push({
      url,
      ...validation,
    });
  }

  info('Validation completed.');
  return results;
}
