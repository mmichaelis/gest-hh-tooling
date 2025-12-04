# GEST Hamburg: Tooling

Tooling to ease administration of [gest-hamburg.de](https://gest-hamburg.de).

This project provides both shell scripts (legacy) and modern TypeScript-based tools for maintaining the GEST Hamburg website.

## Prerequisites

- **Node.js**: v22.11.0 or higher (LTS version recommended)
- **pnpm**: v10.0.0 or higher (required package manager)

## Installation

```bash
# Install pnpm if you don't have it
npm install -g pnpm

# Install dependencies
pnpm install
```

## Available Tools

### Link Validator (TypeScript)

Modern TypeScript implementation for validating links to Stadtteilschulen.

```bash
# Run directly with tsx (development)
cd packages/link-validator
pnpm dev

# Build and run
pnpm build
node dist/cli.js

# With options
pnpm dev -- -f results.csv
pnpm dev -- --help
```

See [packages/link-validator/README.md](packages/link-validator/README.md) for details.

### Legacy Shell Scripts

Original bash implementations (preserved for compatibility):

* [validate-links-sts.sh](bin/validate-links-sts.md) - Link validator for Stadtteilschulen

## Development

```bash
# Lint all packages
pnpm lint

# Fix linting issues
pnpm lint:fix

# Type check
pnpm type-check

# Build all packages
pnpm build

# Run tests
pnpm test
```

## Project Structure

```
.
├── bin/                    # Legacy shell scripts
├── packages/
│   └── link-validator/    # TypeScript link validator
├── scripts/               # Build and utility scripts
├── pnpm-workspace.yaml    # PNPM workspace configuration
└── package.json           # Root package configuration
```

## Contributing

This project uses:
- **PNPM** for package management with workspace support
- **TypeScript** with strict type checking
- **ESLint** with comprehensive strict rules
- **Node.js LTS** (v22.11.0+)

The pre-install hook enforces the use of pnpm to maintain consistency.
