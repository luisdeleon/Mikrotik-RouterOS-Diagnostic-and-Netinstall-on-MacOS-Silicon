#!/usr/bin/env node

import { Command } from 'commander';
import chalk from 'chalk';
import ora from 'ora';
import { ConfigLoader } from './config.js';
import { runDiagnostics, runDiagnosticsOnRouters } from './diagnostics/index.js';
import { DiagnosticCategory, DiagnosticResults } from './types.js';

const program = new Command();

program
  .name('routeros-diag')
  .description('MikroTik RouterOS diagnostics tool')
  .version('1.0.0')
  .option('-r, --router <name>', 'Run diagnostics on a specific router by name')
  .option('-c, --category <type>', 'Run specific diagnostic category (system|interfaces|routing|all)', 'all')
  .option('--config <path>', 'Path to configuration file', 'routers.json')
  .parse(process.argv);

const options = program.opts();

/**
 * Format and display diagnostic results
 */
function displayResults(results: DiagnosticResults[]): void {
  console.log('\n' + chalk.bold.cyan('='.repeat(80)));
  console.log(chalk.bold.cyan('RouterOS Diagnostics Report'));
  console.log(chalk.bold.cyan('='.repeat(80)) + '\n');

  for (const result of results) {
    console.log(chalk.bold.yellow(`\n Router: ${result.router.name}`));
    console.log(chalk.gray(`   Host: ${result.router.host}:${result.router.port}`));
    console.log(chalk.gray(`   Timestamp: ${result.timestamp.toISOString()}\n`));

    if (!result.connected) {
      console.log(chalk.red(`   ✗ Connection failed: ${result.error || 'Unknown error'}\n`));
      continue;
    }

    console.log(chalk.green('   ✓ Connected successfully\n'));

    // System Information
    if (result.system) {
      console.log(chalk.bold('   System Information:'));
      console.log(`     Version:      ${result.system.version}`);
      console.log(`     Board:        ${result.system.boardName}`);
      console.log(`     Architecture: ${result.system.architecture}`);
      console.log(`     CPU:          ${result.system.cpu}`);
      console.log(`     CPU Load:     ${result.system.cpuLoad}`);
      console.log(`     Memory:       ${result.system.freeMemory} / ${result.system.totalMemory}`);
      console.log(`     Uptime:       ${result.system.uptime}\n`);
    }

    // Interfaces
    if (result.interfaces && result.interfaces.length > 0) {
      console.log(chalk.bold('   Interfaces:'));
      for (const iface of result.interfaces) {
        const status = iface.running
          ? chalk.green('UP')
          : iface.disabled
          ? chalk.gray('DISABLED')
          : chalk.red('DOWN');

        console.log(`     ${iface.name.padEnd(20)} ${status.padEnd(20)} ${iface.type}`);

        if (iface.rxBytes || iface.txBytes) {
          console.log(`       RX: ${iface.rxBytes || '0'} bytes (${iface.rxPackets || '0'} packets)`);
          console.log(`       TX: ${iface.txBytes || '0'} bytes (${iface.txPackets || '0'} packets)`);
        }
      }
      console.log();
    }

    // Routing Information
    if (result.routes || result.firewall) {
      console.log(chalk.bold('   Routing:'));

      if (result.routes && result.routes.length > 0) {
        console.log(`     Routes: ${result.routes.length} entries`);
        // Show first 5 routes
        for (const route of result.routes.slice(0, 5)) {
          console.log(`       ${route.dstAddress.padEnd(20)} via ${route.gateway}`);
        }
        if (result.routes.length > 5) {
          console.log(chalk.gray(`       ... and ${result.routes.length - 5} more`));
        }
      }

      if (result.firewall) {
        console.log(`     Firewall Filter Rules: ${result.firewall.filterRules}`);
        console.log(`     NAT Rules: ${result.firewall.natRules}`);
      }

      if (result.bgpPeers && result.bgpPeers.length > 0) {
        console.log(`     BGP Peers: ${result.bgpPeers.length}`);
        for (const peer of result.bgpPeers) {
          const state = peer.state === 'established' ? chalk.green(peer.state) : chalk.yellow(peer.state);
          console.log(`       ${peer.name.padEnd(20)} ${peer.remote.padEnd(20)} ${state}`);
        }
      }

      if (result.ospfNeighbors && result.ospfNeighbors.length > 0) {
        console.log(`     OSPF Neighbors: ${result.ospfNeighbors.length}`);
        for (const neighbor of result.ospfNeighbors) {
          console.log(`       ${neighbor.routerId.padEnd(20)} ${neighbor.address.padEnd(20)} ${neighbor.state}`);
        }
      }

      console.log();
    }

    console.log(chalk.gray('   ' + '-'.repeat(76)));
  }

  console.log('\n' + chalk.bold.cyan('='.repeat(80)) + '\n');
}

/**
 * Main function
 */
async function main(): Promise<void> {
  try {
    const configLoader = new ConfigLoader(options.config);

    // Determine which categories to run
    const categories: DiagnosticCategory[] =
      options.category === 'all'
        ? ['system', 'interfaces', 'routing']
        : [options.category as DiagnosticCategory];

    // Validate category
    const validCategories = ['system', 'interfaces', 'routing', 'all'];
    if (!validCategories.includes(options.category)) {
      console.error(chalk.red(`Invalid category: ${options.category}`));
      console.error(chalk.gray(`Valid categories: ${validCategories.join(', ')}`));
      process.exit(1);
    }

    let results: DiagnosticResults[];

    if (options.router) {
      // Run diagnostics on specific router
      const spinner = ora(`Loading configuration and connecting to ${options.router}...`).start();

      const router = await configLoader.getRouter(options.router);

      if (!router) {
        spinner.fail(chalk.red(`Router "${options.router}" not found in configuration`));
        process.exit(1);
      }

      spinner.text = `Running diagnostics on ${router.name}...`;

      const result = await runDiagnostics(router, categories);
      results = [result];

      spinner.succeed(chalk.green('Diagnostics completed'));
    } else {
      // Run diagnostics on all routers
      const spinner = ora('Loading configuration...').start();

      const routers = await configLoader.getRouters();

      spinner.text = `Running diagnostics on ${routers.length} router(s)...`;

      results = await runDiagnosticsOnRouters(routers, categories);

      spinner.succeed(chalk.green(`Diagnostics completed on ${routers.length} router(s)`));
    }

    // Display results
    displayResults(results);

    // Exit with error code if any router failed
    const hasErrors = results.some((r) => !r.connected || r.error);
    process.exit(hasErrors ? 1 : 0);
  } catch (error) {
    console.error(chalk.red('\n✗ Error:'), error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}

main();
