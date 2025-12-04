#!/usr/bin/env node
/**
 * CLI for validating links to Stadtteilschulen (StS) at
 * https://gest-hamburg.de/stadtteilschulen/.
 *
 * Only links within a table with ID `tablepress-stadtteilschulen` are checked.
 */

import { writeFile } from 'node:fs/promises';
import { Command } from 'commander';
import { resultsToCsv } from './csv-formatter.js';
import { error, info } from './logger.js';
import { DEFAULT_CONFIG, validateLinks } from './validator.js';

const program = new Command();

program
  .name('validate-links-sts')
  .description('Validate links to Stadtteilschulen at gest-hamburg.de')
  .version('1.0.0')
  .option(
    '-f, --file <path>',
    'File to write the CSV output to ("-" for STDOUT)',
    '-'
  )
  .option(
    '--no-bom',
    'Disable BOM (Byte Order Mark) in output'
  )
  .parse();

interface CliOptions {
  readonly file: string;
  readonly bom: boolean;
}

async function main(): Promise<void> {
  const options = program.opts<CliOptions>();

  try {
    // Validate links
    const results = await validateLinks(DEFAULT_CONFIG);

    // Generate CSV
    const csv = resultsToCsv(results, {
      includeBom: options.file !== '-' && options.bom,
      delimiter: DEFAULT_CONFIG.csvDelimiter,
      quote: DEFAULT_CONFIG.csvQuote,
    });

    // Output
    if (options.file === '-') {
      process.stdout.write(csv);
    } else {
      await writeFile(options.file, csv, 'utf8');
      info(`Results written to: ${options.file}`);
    }
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}

await main();
