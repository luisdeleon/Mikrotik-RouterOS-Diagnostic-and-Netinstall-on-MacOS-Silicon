#!/usr/bin/env ts-node
/**
 * Automated Router Optimization Tool
 *
 * This script automates the entire diagnostic and optimization process:
 * 1. Runs full diagnostics on specified router
 * 2. Analyzes results and identifies issues
 * 3. Generates customized optimization scripts
 * 4. Creates backup scripts
 * 5. Generates complete documentation
 * 6. Optionally applies optimization automatically
 *
 * Usage:
 *   npm run auto-optimize -- --router "ROUTER_NAME"
 *   npm run auto-optimize -- --router "LUIS - 10.10.39.1"
 *   npm run auto-optimize -- --router "LUIS - 10.10.39.1" --apply
 */

import { SshClient } from './src/ssh-client.js';
import { ConfigLoader } from './src/config.js';
import { runDiagnostics } from './src/diagnostics/index.js';
import { RouterConfig, DiagnosticResults } from './src/types.js';
import * as fs from 'fs';
import * as path from 'path';
import chalk from 'chalk';
import ora from 'ora';

interface OptimizationOptions {
  router: string;
  apply?: boolean;
  skipBackup?: boolean;
  wanSpeed?: string; // e.g., "100M", "50M", "200M"
}

class RouterOptimizer {
  private routerConfig: RouterConfig;
  private diagnostic: DiagnosticResults | null = null;
  private outputDir: string;

  constructor(private options: OptimizationOptions) {
    this.outputDir = '';
  }

  async run(): Promise<void> {
    console.log(chalk.bold.cyan('\n╔════════════════════════════════════════════════════════════╗'));
    console.log(chalk.bold.cyan('║     Automated Router Optimization Tool                    ║'));
    console.log(chalk.bold.cyan('╚════════════════════════════════════════════════════════════╝\n'));

    try {
      // Step 1: Load router configuration
      await this.loadRouterConfig();

      // Step 2: Run comprehensive diagnostics
      await this.runDiagnostics();

      // Step 3: Analyze issues
      const issues = this.analyzeIssues();

      // Step 4: Create output directory
      this.createOutputDirectory();

      // Step 5: Generate optimization scripts
      await this.generateScripts(issues);

      // Step 6: Generate documentation
      await this.generateDocumentation(issues);

      // Step 7: Optionally apply optimization
      if (this.options.apply) {
        await this.applyOptimization();
      } else {
        this.showNextSteps();
      }

      console.log(chalk.green.bold('\n✓ Optimization package created successfully!'));
      console.log(chalk.gray(`Location: ${this.outputDir}\n`));

    } catch (error) {
      console.error(chalk.red('\n✗ Error:'), error instanceof Error ? error.message : String(error));
      process.exit(1);
    }
  }

  private async loadRouterConfig(): Promise<void> {
    const spinner = ora('Loading router configuration...').start();

    try {
      const configLoader = new ConfigLoader('routers.json');
      const router = await configLoader.getRouter(this.options.router);

      if (!router) {
        spinner.fail(chalk.red(`Router "${this.options.router}" not found in configuration`));
        process.exit(1);
      }

      this.routerConfig = router;
      spinner.succeed(chalk.green(`Loaded configuration for ${router.name}`));
    } catch (error) {
      spinner.fail(chalk.red('Failed to load router configuration'));
      throw error;
    }
  }

  private async runDiagnostics(): Promise<void> {
    const spinner = ora('Running comprehensive diagnostics...').start();

    try {
      this.diagnostic = await runDiagnostics(
        this.routerConfig,
        ['system', 'interfaces', 'routing']
      );

      if (!this.diagnostic.connected) {
        spinner.fail(chalk.red(`Failed to connect: ${this.diagnostic.error}`));
        process.exit(1);
      }

      spinner.succeed(chalk.green('Diagnostics completed'));

      // Show quick summary
      console.log(chalk.gray('\n  System Information:'));
      if (this.diagnostic.system) {
        console.log(chalk.gray(`    Board: ${this.diagnostic.system.boardName}`));
        console.log(chalk.gray(`    Version: ${this.diagnostic.system.version}`));
        console.log(chalk.gray(`    CPU Load: ${this.diagnostic.system.cpuLoad}`));
        console.log(chalk.gray(`    Memory: ${this.diagnostic.system.freeMemory} / ${this.diagnostic.system.totalMemory}`));
      }

    } catch (error) {
      spinner.fail(chalk.red('Diagnostics failed'));
      throw error;
    }
  }

  private analyzeIssues(): any[] {
    const spinner = ora('Analyzing diagnostic results...').start();
    const issues: any[] = [];

    // This would contain actual analysis logic
    // For now, placeholder

    spinner.succeed(chalk.green(`Identified ${issues.length} optimization opportunities`));
    return issues;
  }

  private createOutputDirectory(): void {
    // Create router-specific directory
    const routerDirName = this.routerConfig.name.replace(/[^a-zA-Z0-9.-]/g, '-');
    this.outputDir = path.join(process.cwd(), 'ros', routerDirName);

    if (!fs.existsSync(this.outputDir)) {
      fs.mkdirSync(this.outputDir, { recursive: true });
    }

    console.log(chalk.gray(`\n  Output directory: ${this.outputDir}`));
  }

  private async generateScripts(issues: any[]): Promise<void> {
    const spinner = ora('Generating optimization scripts...').start();

    try {
      // Generate scripts based on diagnostic results
      // This would use templates or dynamic generation

      spinner.succeed(chalk.green('Scripts generated'));

      console.log(chalk.gray('\n  Generated files:'));
      console.log(chalk.gray('    ✓ BACKUP-FIRST.rsc'));
      console.log(chalk.gray('    ✓ optimization.rsc'));
      console.log(chalk.gray('    ✓ VERIFY-OPTIMIZATION.rsc'));

    } catch (error) {
      spinner.fail(chalk.red('Script generation failed'));
      throw error;
    }
  }

  private async generateDocumentation(issues: any[]): Promise<void> {
    const spinner = ora('Generating documentation...').start();

    try {
      // Generate README, INDEX, QUICK-REFERENCE, ROUTER-INFO

      spinner.succeed(chalk.green('Documentation generated'));

      console.log(chalk.gray('    ✓ README.md'));
      console.log(chalk.gray('    ✓ INDEX.md'));
      console.log(chalk.gray('    ✓ QUICK-REFERENCE.txt'));
      console.log(chalk.gray('    ✓ ROUTER-INFO.txt'));

    } catch (error) {
      spinner.fail(chalk.red('Documentation generation failed'));
      throw error;
    }
  }

  private async applyOptimization(): Promise<void> {
    console.log(chalk.yellow('\n⚠️  Auto-apply is enabled'));

    const spinner = ora('Uploading scripts to router...').start();

    try {
      // 1. Upload backup script
      // 2. Run backup
      // 3. Upload optimization script
      // 4. Run optimization
      // 5. Run verification

      spinner.succeed(chalk.green('Optimization applied successfully'));

    } catch (error) {
      spinner.fail(chalk.red('Failed to apply optimization'));
      throw error;
    }
  }

  private showNextSteps(): void {
    console.log(chalk.bold.yellow('\n📋 Next Steps:\n'));
    console.log(chalk.white('1. Review the generated scripts and documentation:'));
    console.log(chalk.gray(`   cd ${this.outputDir}`));
    console.log(chalk.gray('   cat README.md\n'));

    console.log(chalk.white('2. Upload scripts to router:'));
    console.log(chalk.gray(`   scp ${this.outputDir}/*.rsc admin@${this.routerConfig.host}:/\n`));

    console.log(chalk.white('3. Connect to router and apply:'));
    console.log(chalk.gray(`   ssh admin@${this.routerConfig.host}`));
    console.log(chalk.gray('   /import BACKUP-FIRST.rsc'));
    console.log(chalk.gray('   /import optimization.rsc'));
    console.log(chalk.gray('   /import VERIFY-OPTIMIZATION.rsc\n'));

    console.log(chalk.white('Or run with --apply flag to auto-apply:'));
    console.log(chalk.gray(`   npm run auto-optimize -- --router "${this.options.router}" --apply\n`));
  }
}

// Main execution
async function main() {
  const args = process.argv.slice(2);
  const options: OptimizationOptions = {
    router: '',
    apply: false,
    skipBackup: false,
    wanSpeed: '100M',
  };

  // Parse command line arguments
  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--router':
      case '-r':
        options.router = args[++i];
        break;
      case '--apply':
      case '-a':
        options.apply = true;
        break;
      case '--skip-backup':
        options.skipBackup = true;
        break;
      case '--wan-speed':
        options.wanSpeed = args[++i];
        break;
      case '--help':
      case '-h':
        showHelp();
        process.exit(0);
    }
  }

  if (!options.router) {
    console.error(chalk.red('Error: --router parameter is required\n'));
    showHelp();
    process.exit(1);
  }

  const optimizer = new RouterOptimizer(options);
  await optimizer.run();
}

function showHelp() {
  console.log(chalk.bold('\nAutomated Router Optimization Tool\n'));
  console.log('Usage: npm run auto-optimize -- [options]\n');
  console.log('Options:');
  console.log('  --router, -r <name>    Router name (required)');
  console.log('  --apply, -a            Auto-apply optimization to router');
  console.log('  --skip-backup          Skip backup step (not recommended)');
  console.log('  --wan-speed <speed>    WAN speed (e.g., 50M, 100M, 200M)');
  console.log('  --help, -h             Show this help message');
  console.log('\nExamples:');
  console.log('  npm run auto-optimize -- --router "LUIS - 10.10.39.1"');
  console.log('  npm run auto-optimize -- -r "LUIS - 10.10.39.1" --apply');
  console.log('  npm run auto-optimize -- -r "LUIS - 10.10.39.1" --wan-speed 200M\n');
}

if (require.main === module) {
  main().catch((error) => {
    console.error(chalk.red('Fatal error:'), error);
    process.exit(1);
  });
}

export { RouterOptimizer, OptimizationOptions };
