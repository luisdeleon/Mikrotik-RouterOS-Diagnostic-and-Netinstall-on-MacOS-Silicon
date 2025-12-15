import { Client, ConnectConfig } from 'ssh2';
import { RouterConfig } from './types.js';

/**
 * SSH Client wrapper for RouterOS
 */
export class SshClient {
  private client: Client;
  private config: RouterConfig;

  constructor(config: RouterConfig) {
    this.client = new Client();
    this.config = config;
  }

  /**
   * Connect to the RouterOS device
   */
  async connect(): Promise<void> {
    return new Promise((resolve, reject) => {
      const connectConfig: ConnectConfig = {
        host: this.config.host,
        port: this.config.port,
        username: this.config.username,
        password: this.config.password,
        readyTimeout: 10000,
        keepaliveInterval: 5000,
      };

      this.client
        .on('ready', () => {
          resolve();
        })
        .on('error', (err) => {
          reject(err);
        })
        .connect(connectConfig);
    });
  }

  /**
   * Execute a command on the RouterOS device
   */
  async executeCommand(command: string): Promise<string> {
    return new Promise((resolve, reject) => {
      this.client.exec(command, (err, stream) => {
        if (err) {
          reject(err);
          return;
        }

        let output = '';
        let errorOutput = '';

        stream
          .on('close', () => {
            if (errorOutput) {
              reject(new Error(errorOutput));
            } else {
              resolve(output);
            }
          })
          .on('data', (data: Buffer) => {
            output += data.toString();
          })
          .stderr.on('data', (data: Buffer) => {
            errorOutput += data.toString();
          });
      });
    });
  }

  /**
   * Execute multiple commands sequentially
   */
  async executeCommands(commands: string[]): Promise<Map<string, string>> {
    const results = new Map<string, string>();

    for (const command of commands) {
      try {
        const output = await this.executeCommand(command);
        results.set(command, output);
      } catch (error) {
        results.set(command, `Error: ${error}`);
      }
    }

    return results;
  }

  /**
   * Disconnect from the RouterOS device
   */
  disconnect(): void {
    this.client.end();
  }

  /**
   * Test connection to the RouterOS device
   */
  async testConnection(): Promise<boolean> {
    try {
      await this.connect();
      await this.executeCommand('/system identity print');
      this.disconnect();
      return true;
    } catch (error) {
      return false;
    }
  }
}
