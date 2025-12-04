/**
 * Main calendar generator module.
 */

import type { CalendarEvent, ParsedInputLine } from './types.js';
import { parseDate, formatISODate } from './date-utils.js';
import { getEventType, loadEventDescription, DEFAULT_EVENT_TYPE } from './event-registry.js';
import { info, debug } from './logger.js';

/**
 * Generate calendar events from parsed input lines.
 */
export async function generateEvents(
  inputLines: readonly ParsedInputLine[]
): Promise<CalendarEvent[]> {
  info(`Generating ${String(inputLines.length)} calendar events...`);

  const events: CalendarEvent[] = [];
  const descriptionCache = new Map<string, string>();

  for (const line of inputLines) {
    try {
      const eventTypeId = line.eventType ?? DEFAULT_EVENT_TYPE;
      const config = getEventType(eventTypeId);

      // Load description template (with caching)
      let description = descriptionCache.get(config.descriptionTemplate);
      if (description === undefined) {
        description = await loadEventDescription(config.descriptionTemplate);
        descriptionCache.set(config.descriptionTemplate, description);
      }

      // Parse date
      const date = parseDate(line.dateString);
      const isoDate = formatISODate(date);

      // Create event
      const event: CalendarEvent = {
        eventName: config.defaultEventName,
        eventDescription: description,
        eventStartDate: isoDate,
        eventStartTime: config.defaultStartTime,
        eventEndDate: isoDate,
        eventEndTime: config.defaultEndTime,
        allDayEvent: false,
        timezone: config.defaultTimezone,
        ...(config.defaultVenue !== undefined && { eventVenueName: config.defaultVenue }),
        ...(config.defaultOrganizer !== undefined && { eventOrganizerName: config.defaultOrganizer }),
        ...(config.defaultWebsite !== undefined && { eventWebsite: config.defaultWebsite }),
        eventShowMapLink: config.showMapLink,
        eventShowMap: config.showMap,
        stickyInMonthView: config.stickyInMonthView,
      };

      events.push(event);
      debug(`Generated event: ${event.eventName} on ${event.eventStartDate}`);

    } catch (err) {
      throw new Error(
        `Error processing line ${String(line.lineNumber)} ("${line.dateString}"): ${err instanceof Error ? err.message : String(err)}`
      );
    }
  }

  info(`Successfully generated ${String(events.length)} events.`);
  return events;
}
