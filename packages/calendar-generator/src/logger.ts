/**
 * Logging utilities (reusing pattern from link-validator).
 */

const DEBUG = process.env['DEBUG'] === '1';

function isTTY(): boolean {
  return process.stderr.isTTY;
}

export function debug(message: string): void {
  if (DEBUG) {
    const formatted = isTTY()
      ? `\x1b[90m[DEBUG] ${message}\x1b[0m`
      : `[DEBUG] ${message}`;
    console.error(formatted);
  }
}

export function info(message: string): void {
  console.error(`[INFO] ${message}`);
}

export function error(message: string): void {
  const formatted = isTTY()
    ? `\x1b[31m[ERROR] ${message}\x1b[0m`
    : `[ERROR] ${message}`;
  console.error(formatted);
}
