/**
 * CSV formatter for The Events Calendar plugin.
 */

import { stringify } from 'csv-stringify/sync';
import type { CalendarEvent, CsvOutputOptions } from './types.js';

const BOM = '\uFEFF';

/**
 * Column order for The Events Calendar CSV format.
 */
const CSV_COLUMNS = [
  'EVENT NAME',
  'EVENT EXCERPT',
  'EVENT VENUE NAME',
  'EVENT ORGANIZER NAME',
  'EVENT START DATE',
  'EVENT START TIME',
  'EVENT END DATE',
  'EVENT END TIME',
  'ALL DAY EVENT',
  'TIMEZONE',
  'HIDE FROM EVENT LISTINGS',
  'STICKY IN MONTH VIEW',
  'EVENT CATEGORY',
  'EVENT TAGS',
  'EVENT COST',
  'EVENT CURRENCY SYMBOL',
  'EVENT CURRENCY POSITION',
  'EVENT ISO CURRENCY CODE',
  'EVENT FEATURED IMAGE',
  'EVENT WEBSITE',
  'EVENT SHOW MAP LINK',
  'EVENT SHOW MAP',
  'ALLOW COMMENTS',
  'ALLOW TRACKBACKS AND PINGBACKS',
  'EVENT DESCRIPTION',
] as const;

/**
 * Convert calendar event to CSV row array.
 */
function eventToRow(event: CalendarEvent): string[] {
  return [
    event.eventName,
    event.eventExcerpt ?? '',
    event.eventVenueName ?? '',
    event.eventOrganizerName ?? '',
    event.eventStartDate,
    event.eventStartTime,
    event.eventEndDate,
    event.eventEndTime,
    event.allDayEvent ? 'TRUE' : 'FALSE',
    event.timezone,
    'FALSE', // HIDE FROM EVENT LISTINGS
    event.stickyInMonthView ? 'TRUE' : 'FALSE',
    event.eventCategory ?? '',
    event.eventTags ?? '',
    event.eventCost ?? '',
    '', // EVENT CURRENCY SYMBOL
    '', // EVENT CURRENCY POSITION
    '', // EVENT ISO CURRENCY CODE
    '', // EVENT FEATURED IMAGE
    event.eventWebsite ?? '',
    event.eventShowMapLink ? 'TRUE' : 'FALSE',
    event.eventShowMap ? 'TRUE' : 'FALSE',
    'FALSE', // ALLOW COMMENTS
    'FALSE', // ALLOW TRACKBACKS AND PINGBACKS
    event.eventDescription,
  ];
}

/**
 * Convert calendar events to CSV format.
 */
export function eventsToCSV(
  events: readonly CalendarEvent[],
  options: CsvOutputOptions
): string {
  const records = [
    [...CSV_COLUMNS],
    ...events.map(eventToRow),
  ];

  const csv = stringify(records, {
    delimiter: options.delimiter,
    quoted: true,
    quoted_empty: true,
  });

  return options.includeBom ? BOM + csv : csv;
}
