/**
 * Type definitions for the link validator.
 */

/**
 * Configuration for the link validator.
 */
export interface ValidatorConfig {
  /** The URL to fetch and validate links from */
  readonly url: string;
  /** The ID of the HTML table to extract links from */
  readonly tableId: string;
  /** User-Agent string for HTTP requests */
  readonly userAgent: string;
  /** CSV delimiter character */
  readonly csvDelimiter: string;
  /** CSV quote character */
  readonly csvQuote: string;
}

/**
 * Result of validating a single link.
 */
export interface LinkValidationResult {
  /** The original URL */
  readonly url: string;
  /** HTTP status code */
  readonly statusCode: number;
  /** The effective URL after redirects */
  readonly effectiveUrl: string;
  /** Page title */
  readonly title: string;
}

/**
 * Options for CSV output.
 */
export interface CsvOutputOptions {
  /** Whether to include BOM (Byte Order Mark) for Excel compatibility */
  readonly includeBom: boolean;
  /** CSV delimiter character */
  readonly delimiter: string;
  /** CSV quote character */
  readonly quote: string;
}
