/**
 * Logging utilities for outputting information.
 * All logs go to stderr to keep stdout clean for data output.
 */

const DEBUG = process.env['DEBUG'] === '1';

/**
 * Check if stderr is a TTY (terminal) for colored output.
 */
function isTTY(): boolean {
  return process.stderr.isTTY;
}

/**
 * Log a debug message (only when DEBUG=1 environment variable is set).
 */
export function debug(message: string): void {
  if (DEBUG) {
    const formatted = isTTY()
      ? `\x1b[90m[DEBUG] ${message}\x1b[0m`
      : `[DEBUG] ${message}`;
    console.error(formatted);
  }
}

/**
 * Log an info message to stderr.
 */
export function info(message: string): void {
  console.error(`[INFO] ${message}`);
}

/**
 * Log an error message to stderr.
 */
export function error(message: string): void {
  const formatted = isTTY()
    ? `\x1b[31m[ERROR] ${message}\x1b[0m`
    : `[ERROR] ${message}`;
  console.error(formatted);
}
