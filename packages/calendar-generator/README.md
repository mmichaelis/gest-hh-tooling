# Calendar Generator

Generate WordPress-compatible calendar CSV files from simple date lists for The Events Calendar plugin.

## Features

- Parse dates in ISO (`2026-12-08`) or German (`08.12.2026`) format
- Support for extensible event types
- Generate CSV files compatible with The Events Calendar WordPress plugin
- Configurable event templates with HTML descriptions
- Modular, reusable architecture

## Usage

### Command Line

```bash
# From simple date list
pnpm dev -i dates.txt -o calendar.csv

# Output to stdout
pnpm tsx src/cli.ts -i dates.txt

# With event types
pnpm tsx src/cli.ts -i events.txt -o calendar.csv
```

### Input File Formats

**Simple dates** (uses default event type: GEST-Sitzung):
```text
12.01.2026
09.02.2026
2026-03-17
```

**With event types**:
```text
GEST-Sitzung,12.01.2026
GEST-Sitzung,09.02.2026
GEST-Sitzung,2026-03-17
```

### As a Library

```typescript
import { parseInputLines, generateEvents, eventsToCSV } from '@gest-hh/calendar-generator';
import { readFile } from 'node:fs/promises';

// Read and parse input
const content = await readFile('dates.txt', 'utf-8');
const lines = parseInputLines(content);

// Generate events
const events = await generateEvents(lines);

// Convert to CSV
const csv = eventsToCSV(events, {
  includeBom: true,
  delimiter: ',',
});
```

## Event Types

### GEST-Sitzung (Default)

- **Time**: 19:30 - 21:15
- **Venue**: BSFB, Sitzungsraum M, 3. Stock
- **Organizer**: GEST Hamburg
- **Timezone**: Europe/Berlin
- **Website**: <https://gest-hamburg.de/>
- **Map**: Enabled
- **Sticky**: Yes

### Adding New Event Types

```typescript
import { registerEventType, Venue } from '@gest-hh/calendar-generator';

registerEventType({
  id: 'Workshop',
  displayName: 'Workshop',
  defaultEventName: 'GEST Workshop',
  descriptionTemplate: 'Workshop.html',
  defaultStartTime: '14:00:00',
  defaultEndTime: '17:00:00',
  defaultVenue: Venue.BSFB_M,
  defaultOrganizer: 'GEST Hamburg',
  defaultWebsite: 'https://gest-hamburg.de/',
  defaultTimezone: 'Europe/Berlin',
  showMap: true,
  showMapLink: true,
  stickyInMonthView: false,
});
```

## Output Format

Generates CSV compatible with [The Events Calendar](https://theeventscalendar.com/) WordPress plugin with all required columns:

- EVENT NAME
- EVENT START DATE / TIME
- EVENT END DATE / TIME
- TIMEZONE
- VENUE, ORGANIZER
- EVENT WEBSITE
- MAP SETTINGS
- And more...

## Templates

Event descriptions are stored as HTML templates in `templates/`:

- `GEST-Sitzung.html` - GEST meeting description

Templates support full HTML formatting and are loaded dynamically.

## Development

```bash
# Build
pnpm build

# Lint
pnpm lint

# Type check
pnpm type-check
```

## Architecture

Modular design for extensibility:

- `types.ts` - Type definitions
- `logger.ts` - Logging utilities
- `date-utils.ts` - Date parsing (ISO & German formats)
- `event-registry.ts` - Event type management
- `input-parser.ts` - Input file parsing
- `generator.ts` - Event generation
- `csv-formatter.ts` - CSV output
- `cli.ts` - Command-line interface
- `index.ts` - Public API

## Requirements

- Node.js >= 22.11.0 (LTS)
- Dependencies managed via PNPM workspace catalog
