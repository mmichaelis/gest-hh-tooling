/**
 * Event type registry for extensible event type management.
 */

import { readFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import type { EventTypeConfig } from './types.js';
import { Venue } from './types.js';
import { debug } from './logger.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const TEMPLATES_DIR = join(__dirname, '../templates');

/**
 * Built-in event type configurations.
 */
const EVENT_TYPES = new Map<string, EventTypeConfig>([
  ['GEST-Sitzung', {
    id: 'GEST-Sitzung',
    displayName: 'GEST-Sitzung',
    defaultEventName: 'GEST-Sitzung',
    descriptionTemplate: 'GEST-Sitzung.html',
    defaultStartTime: '19:30:00',
    defaultEndTime: '21:15:00',
    defaultVenue: Venue.BSFB_M,
    defaultOrganizer: 'GEST Hamburg',
    defaultWebsite: 'https://gest-hamburg.de/',
    defaultTimezone: 'Europe/Berlin',
    showMap: true,
    showMapLink: true,
    stickyInMonthView: true,
  }],
]);

/**
 * Default event type (used when no type is specified).
 */
export const DEFAULT_EVENT_TYPE = 'GEST-Sitzung';

/**
 * Get event type configuration by ID.
 */
export function getEventType(id: string): EventTypeConfig {
  const config = EVENT_TYPES.get(id);
  if (config === undefined) {
    throw new Error(`Unknown event type: "${id}". Available types: ${[...EVENT_TYPES.keys()].join(', ')}`);
  }
  return config;
}

/**
 * Get all registered event type IDs.
 */
export function getAllEventTypeIds(): string[] {
  return [...EVENT_TYPES.keys()];
}

/**
 * Register a new event type (for future extensions).
 */
export function registerEventType(config: EventTypeConfig): void {
  if (EVENT_TYPES.has(config.id)) {
    throw new Error(`Event type "${config.id}" is already registered`);
  }
  EVENT_TYPES.set(config.id, config);
  debug(`Registered event type: ${config.id}`);
}

/**
 * Load event description template from file.
 */
export async function loadEventDescription(templateFilename: string): Promise<string> {
  const templatePath = join(TEMPLATES_DIR, templateFilename);
  debug(`Loading template: ${templatePath}`);

  try {
    const content = await readFile(templatePath, 'utf-8');
    return content.trim();
  } catch (err) {
    throw new Error(`Failed to load template "${templateFilename}": ${err instanceof Error ? err.message : String(err)}`);
  }
}
