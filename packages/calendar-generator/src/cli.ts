#!/usr/bin/env node
/**
 * CLI for generating calendar CSV files from date lists.
 */

import { readFile, writeFile } from 'node:fs/promises';
import { Command } from 'commander';
import { parseInputLines } from './input-parser.js';
import { generateEvents } from './generator.js';
import { eventsToCSV } from './csv-formatter.js';
import { error, info } from './logger.js';

const program = new Command();

program
  .name('generate-calendar')
  .description('Generate calendar CSV files for WordPress import from simple date lists')
  .version('1.0.0')
  .requiredOption(
    '-i, --input <path>',
    'Input file containing dates (one per line)'
  )
  .option(
    '-o, --output <path>',
    'Output CSV file ("-" for STDOUT)',
    '-'
  )
  .option(
    '--no-bom',
    'Disable BOM (Byte Order Mark) in output'
  )
  .parse();

interface CliOptions {
  readonly input: string;
  readonly output: string;
  readonly bom: boolean;
}

async function main(): Promise<void> {
  const options = program.opts<CliOptions>();

  try {
    // Read input file
    info(`Reading input from: ${options.input}`);
    const inputContent = await readFile(options.input, 'utf-8');

    // Parse input
    const inputLines = parseInputLines(inputContent);
    if (inputLines.length === 0) {
      throw new Error('No valid input lines found in file');
    }

    // Generate events
    const events = await generateEvents(inputLines);

    // Generate CSV
    const csv = eventsToCSV(events, {
      includeBom: options.output !== '-' && options.bom,
      delimiter: ',',
    });

    // Output
    if (options.output === '-') {
      process.stdout.write(csv);
    } else {
      await writeFile(options.output, csv, 'utf-8');
      info(`Calendar CSV written to: ${options.output}`);
    }
  } catch (err) {
    error(err instanceof Error ? err.message : String(err));
    process.exit(1);
  }
}

await main();
