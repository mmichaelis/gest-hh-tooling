/**
 * HTML entity decoding and manipulation utilities.
 */

/**
 * HTML entities to decode.
 */
const ENTITY_MAP: Record<string, string> = {
  '&amp;': '&',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&nbsp;': ' ',
  '&#8211;': '-', // en dash
} as const;

/**
 * Replace common HTML entities with their corresponding characters.
 */
export function decodeEntities(text: string): string {
  let result = text;

  for (const [entity, char] of Object.entries(ENTITY_MAP)) {
    result = result.replaceAll(entity, char);
  }

  return result;
}

/**
 * Extract the host from a URL and remove leading 'www.'.
 */
export function getHostFromUrl(url: string): string {
  try {
    const urlObj = new URL(url);
    const host = urlObj.hostname;
    return host.replace(/^www\./, '');
  } catch {
    // Fallback to regex if URL parsing fails
    const match = /https?:\/\/(?<host>[^/]+)/.exec(url);
    const host = match?.groups?.['host'] ?? url;
    return host.replace(/^www\./, '');
  }
}
