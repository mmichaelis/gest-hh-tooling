/**
 * HTTP client utilities for fetching and validating URLs.
 */

import axios, { type AxiosInstance } from 'axios';
import * as cheerio from 'cheerio';
import { decodeEntities, getHostFromUrl } from './html-utils.js';
import { debug, info } from './logger.js';
import type { ValidatorConfig } from './types.js';

/**
 * Create an axios instance configured for the validator.
 */
function createHttpClient(userAgent: string): AxiosInstance {
  return axios.create({
    headers: {
      'User-Agent': userAgent,
    },
    timeout: 30000, // 30 second timeout
    maxRedirects: 5,
    validateStatus: () => true, // Accept any status code
  });
}

/**
 * Extract links from a table with the specified ID.
 */
export async function extractLinksFromTable(
  config: ValidatorConfig
): Promise<string[]> {
  debug(`Fetching URL: ${config.url}`);

  const client = createHttpClient(config.userAgent);
  const response = await client.get(config.url);

  if (response.status !== 200) {
    throw new Error(`Failed to fetch ${config.url}: HTTP ${response.status}`);
  }

  const $ = cheerio.load(response.data as string);
  const table = $(`table#${config.tableId}`);

  if (table.length === 0) {
    throw new Error(`Table with ID "${config.tableId}" not found`);
  }

  const links: string[] = [];

  // Extract links from table cells
  table.find('td').each((_index, element) => {
    const text = $(element).text().trim();
    if (text.startsWith('http://') || text.startsWith('https://')) {
      links.push(text);
    }
  });

  debug(`Extracted ${links.length} links from table`);
  return links;
}

/**
 * Get all title elements from a page.
 */
async function getTitles(url: string, userAgent: string): Promise<string[]> {
  try {
    const client = createHttpClient(userAgent);
    const response = await client.get(url);

    if (response.status !== 200) {
      return [];
    }

    const $ = cheerio.load(response.data as string);
    const titles: string[] = [];

    $('title').each((_index, element) => {
      const title = $(element).text().trim();
      if (title.length > 0) {
        titles.push(title);
      }
    });

    return titles;
  } catch (err) {
    debug(`Error fetching titles for ${url}: ${String(err)}`);
    return [];
  }
}

/**
 * Get the first non-empty title from a page, or the hostname if no title exists.
 */
async function getFirstNonEmptyTitleOrHost(
  url: string,
  userAgent: string
): Promise<string> {
  const titles = await getTitles(url, userAgent);
  const firstTitle = titles.find((title) => title.length > 0);

  if (firstTitle !== undefined) {
    return decodeEntities(firstTitle);
  }

  return getHostFromUrl(url);
}

/**
 * Validate a single link and return detailed information.
 */
export async function validateLink(
  url: string,
  userAgent: string
): Promise<{ statusCode: number; effectiveUrl: string; title: string }> {
  info(`Validating: ${url}`);

  const client = createHttpClient(userAgent);

  try {
    const response = await client.get(url);
    const statusCode = response.status;
    const effectiveUrl = response.request?.res?.responseUrl as string | undefined ?? url;
    const title = await getFirstNonEmptyTitleOrHost(effectiveUrl, userAgent);

    debug(`  Status: ${statusCode}, Effective: ${effectiveUrl}`);

    return {
      statusCode,
      effectiveUrl,
      title,
    };
  } catch (err) {
    debug(`  Error: ${String(err)}`);

    // Return error information
    return {
      statusCode: 0,
      effectiveUrl: url,
      title: `Error: ${err instanceof Error ? err.message : String(err)}`,
    };
  }
}
