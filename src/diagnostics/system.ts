import { SshClient } from '../ssh-client.js';
import { SystemResource } from '../types.js';

/**
 * Parse system resource output from RouterOS
 */
function parseSystemResource(output: string): Partial<SystemResource> {
  const lines = output.split('\n');
  const resource: Partial<SystemResource> = {};

  for (const line of lines) {
    const trimmed = line.trim();

    if (trimmed.includes('uptime:')) {
      resource.uptime = trimmed.split('uptime:')[1]?.trim() || 'unknown';
    } else if (trimmed.includes('version:')) {
      resource.version = trimmed.split('version:')[1]?.trim() || 'unknown';
    } else if (trimmed.includes('cpu:')) {
      resource.cpu = trimmed.split('cpu:')[1]?.trim() || 'unknown';
    } else if (trimmed.includes('cpu-load:')) {
      resource.cpuLoad = trimmed.split('cpu-load:')[1]?.trim() || 'unknown';
    } else if (trimmed.includes('free-memory:')) {
      resource.freeMemory = trimmed.split('free-memory:')[1]?.trim() || 'unknown';
    } else if (trimmed.includes('total-memory:')) {
      resource.totalMemory = trimmed.split('total-memory:')[1]?.trim() || 'unknown';
    } else if (trimmed.includes('architecture-name:')) {
      resource.architecture = trimmed.split('architecture-name:')[1]?.trim() || 'unknown';
    } else if (trimmed.includes('board-name:')) {
      resource.boardName = trimmed.split('board-name:')[1]?.trim() || 'unknown';
    }
  }

  return resource;
}

/**
 * Get system diagnostics from RouterOS
 */
export async function getSystemDiagnostics(client: SshClient): Promise<SystemResource> {
  const commands = [
    '/system resource print',
    '/system routerboard print',
  ];

  const results = await client.executeCommands(commands);

  let systemInfo: Partial<SystemResource> = {};

  for (const [command, output] of results) {
    if (command.includes('resource')) {
      systemInfo = { ...systemInfo, ...parseSystemResource(output) };
    } else if (command.includes('routerboard')) {
      const boardInfo = parseSystemResource(output);
      if (boardInfo.boardName) {
        systemInfo.boardName = boardInfo.boardName;
      }
    }
  }

  return {
    uptime: systemInfo.uptime || 'unknown',
    version: systemInfo.version || 'unknown',
    cpu: systemInfo.cpu || 'unknown',
    cpuLoad: systemInfo.cpuLoad || 'unknown',
    freeMemory: systemInfo.freeMemory || 'unknown',
    totalMemory: systemInfo.totalMemory || 'unknown',
    architecture: systemInfo.architecture || 'unknown',
    boardName: systemInfo.boardName || 'unknown',
  };
}
