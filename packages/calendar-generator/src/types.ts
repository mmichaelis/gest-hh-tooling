/**
 * Type definitions for the calendar generator.
 */

/**
 * Venue locations for events.
 */
export enum Venue {
  /** BSFB, Sitzungsraum M, 3. Stock */
  BSFB_M = 'BSFB, Sitzungsraum M, 3. Stock',
}

/**
 * Complete event data for calendar export.
 */
export interface CalendarEvent {
  /** Event name/title */
  readonly eventName: string;
  /** Event description (can contain HTML) */
  readonly eventDescription: string;
  /** Brief excerpt (optional) */
  readonly eventExcerpt?: string;
  /** Start date (YYYY-MM-DD format) */
  readonly eventStartDate: string;
  /** Start time (HH:MM:SS format or H:MM AM/PM) */
  readonly eventStartTime: string;
  /** End date (YYYY-MM-DD format) */
  readonly eventEndDate: string;
  /** End time (HH:MM:SS format or H:MM AM/PM) */
  readonly eventEndTime: string;
  /** Is this an all-day event? */
  readonly allDayEvent: boolean;
  /** IANA timezone (e.g., Europe/Berlin) */
  readonly timezone: string;
  /** Venue name */
  readonly eventVenueName?: string;
  /** Organizer name(s) */
  readonly eventOrganizerName?: string;
  /** Event website URL */
  readonly eventWebsite?: string;
  /** Show map link */
  readonly eventShowMapLink: boolean;
  /** Show embedded map */
  readonly eventShowMap: boolean;
  /** Sticky in month view */
  readonly stickyInMonthView: boolean;
  /** Event categories (comma-separated) */
  readonly eventCategory?: string;
  /** Event tags (comma-separated) */
  readonly eventTags?: string;
  /** Event cost */
  readonly eventCost?: string;
}

/**
 * Configuration for an event type.
 */
export interface EventTypeConfig {
  /** Unique identifier for this event type */
  readonly id: string;
  /** Display name */
  readonly displayName: string;
  /** Default event name if not specified */
  readonly defaultEventName: string;
  /** Path to HTML template file for description */
  readonly descriptionTemplate: string;
  /** Default start time (HH:MM:SS) */
  readonly defaultStartTime: string;
  /** Default end time (HH:MM:SS) */
  readonly defaultEndTime: string;
  /** Default venue */
  readonly defaultVenue?: Venue;
  /** Default organizer */
  readonly defaultOrganizer?: string;
  /** Default website */
  readonly defaultWebsite?: string;
  /** Default timezone */
  readonly defaultTimezone: string;
  /** Show map by default */
  readonly showMap: boolean;
  /** Show map link by default */
  readonly showMapLink: boolean;
  /** Sticky in month view by default */
  readonly stickyInMonthView: boolean;
}

/**
 * Input line parsed from file.
 */
export interface ParsedInputLine {
  /** Event type identifier (optional, uses default if not specified) */
  readonly eventType?: string;
  /** Date string (in any supported format) */
  readonly dateString: string;
  /** Original line number for error reporting */
  readonly lineNumber: number;
}

/**
 * Options for CSV output.
 */
export interface CsvOutputOptions {
  /** Whether to include BOM (Byte Order Mark) for Excel compatibility */
  readonly includeBom: boolean;
  /** CSV delimiter character */
  readonly delimiter: string;
}
