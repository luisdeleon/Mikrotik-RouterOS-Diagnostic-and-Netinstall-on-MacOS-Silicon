import { readFile } from 'fs/promises';
import { resolve } from 'path';
import { Config, RouterConfig } from './types.js';

/**
 * Load and validate router configuration from JSON file
 */
export class ConfigLoader {
  private configPath: string;

  constructor(configPath: string = 'routers.json') {
    this.configPath = resolve(process.cwd(), configPath);
  }

  /**
   * Load configuration from file
   */
  async load(): Promise<Config> {
    try {
      const content = await readFile(this.configPath, 'utf-8');
      const config = JSON.parse(content) as Config;

      this.validate(config);

      return config;
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
        throw new Error(
          `Configuration file not found: ${this.configPath}\n` +
          'Please create a routers.json file based on routers.example.json'
        );
      }
      throw error;
    }
  }

  /**
   * Validate configuration structure
   */
  private validate(config: Config): void {
    if (!config.routers || !Array.isArray(config.routers)) {
      throw new Error('Configuration must contain a "routers" array');
    }

    if (config.routers.length === 0) {
      throw new Error('Configuration must contain at least one router');
    }

    config.routers.forEach((router, index) => {
      this.validateRouter(router, index);
    });
  }

  /**
   * Validate individual router configuration
   */
  private validateRouter(router: RouterConfig, index: number): void {
    const requiredFields: (keyof RouterConfig)[] = [
      'name',
      'host',
      'port',
      'username',
      'password',
    ];

    for (const field of requiredFields) {
      if (!router[field]) {
        throw new Error(
          `Router at index ${index} is missing required field: ${field}`
        );
      }
    }

    if (typeof router.port !== 'number' || router.port < 1 || router.port > 65535) {
      throw new Error(
        `Router "${router.name}" has invalid port: ${router.port}`
      );
    }
  }

  /**
   * Get router by name
   */
  async getRouter(name: string): Promise<RouterConfig | undefined> {
    const config = await this.load();
    return config.routers.find((router) => router.name === name);
  }

  /**
   * Get all routers
   */
  async getRouters(): Promise<RouterConfig[]> {
    const config = await this.load();
    return config.routers;
  }
}
