# Link Validator

TypeScript-based tool for validating links to Stadtteilschulen (StS) at https://gest-hamburg.de/stadtteilschulen/.

## Features

- Extracts links from HTML tables by ID
- Validates HTTP status codes
- Follows redirects and reports effective URLs
- Extracts page titles with HTML entity decoding
- Outputs CSV format compatible with Excel (German locale)
- Modular architecture for easy reuse and extension

## Usage

### Command Line

```bash
# Output to stdout
pnpm dev

# Write to CSV file
pnpm dev -- -f results.csv

# Disable BOM (Byte Order Mark)
pnpm dev -- -f results.csv --no-bom

# Show help
pnpm dev -- --help
```

### As a Library

```typescript
import { validateLinks, resultsToCsv, DEFAULT_CONFIG } from '@gest-hh/link-validator';

// Validate links
const results = await validateLinks(DEFAULT_CONFIG);

// Convert to CSV
const csv = resultsToCsv(results, {
  includeBom: true,
  delimiter: ';',
  quote: '"',
});

console.log(csv);
```

### Custom Configuration

```typescript
import { validateLinks } from '@gest-hh/link-validator';

const results = await validateLinks({
  url: 'https://example.com/page',
  tableId: 'my-table-id',
  userAgent: 'MyBot/1.0',
  csvDelimiter: ';',
  csvQuote: '"',
});
```

## Output Format

The tool generates a CSV file with the following columns:

- **URL**: The original URL from the table
- **Status**: HTTP status code (200, 404, etc.)
- **Effective URL**: The final URL after redirects
- **Title**: The page title (or hostname if no title)

## Development

```bash
# Install dependencies
pnpm install

# Run in development mode
pnpm dev

# Build
pnpm build

# Lint
pnpm lint

# Type check
pnpm type-check

# Run tests
pnpm test
```

## Architecture

The package is structured into focused modules:

- `types.ts` - TypeScript type definitions
- `logger.ts` - Logging utilities (output to stderr)
- `html-utils.ts` - HTML parsing and entity decoding
- `csv-formatter.ts` - CSV output generation
- `http-client.ts` - HTTP requests and link extraction
- `validator.ts` - Main validation orchestration
- `cli.ts` - Command-line interface
- `index.ts` - Public API exports

This modular design makes it easy to:

- Reuse components in other tools
- Test individual functions
- Extend functionality
- Maintain code quality

## Requirements

- Node.js >= 22.11.0 (LTS)
- Dependencies are managed via PNPM workspace catalog
