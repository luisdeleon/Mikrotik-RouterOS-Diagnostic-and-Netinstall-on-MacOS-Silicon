import { SshClient } from '../ssh-client.js';
import { InterfaceStatus } from '../types.js';

/**
 * Parse interface list output from RouterOS
 */
function parseInterfaces(output: string): InterfaceStatus[] {
  const interfaces: InterfaceStatus[] = [];
  const lines = output.split('\n');

  let currentInterface: Partial<InterfaceStatus> = {};

  for (const line of lines) {
    const trimmed = line.trim();

    // Skip empty lines and headers
    if (!trimmed || trimmed.startsWith('Flags:') || trimmed.startsWith('#')) {
      if (currentInterface.name) {
        interfaces.push(currentInterface as InterfaceStatus);
        currentInterface = {};
      }
      continue;
    }

    // Parse interface properties
    if (trimmed.includes('name=')) {
      const match = trimmed.match(/name="?([^"]+)"?/);
      if (match) {
        currentInterface.name = match[1];
      }
    }
    if (trimmed.includes('type=')) {
      const match = trimmed.match(/type=(\S+)/);
      if (match) {
        currentInterface.type = match[1];
      }
    }
    if (trimmed.includes('running=')) {
      currentInterface.running = trimmed.includes('running=true');
    }
    if (trimmed.includes('disabled=')) {
      currentInterface.disabled = trimmed.includes('disabled=true');
    }
    if (trimmed.includes('rx-byte=')) {
      const match = trimmed.match(/rx-byte=(\S+)/);
      if (match) {
        currentInterface.rxBytes = match[1];
      }
    }
    if (trimmed.includes('tx-byte=')) {
      const match = trimmed.match(/tx-byte=(\S+)/);
      if (match) {
        currentInterface.txBytes = match[1];
      }
    }
    if (trimmed.includes('rx-packet=')) {
      const match = trimmed.match(/rx-packet=(\S+)/);
      if (match) {
        currentInterface.rxPackets = match[1];
      }
    }
    if (trimmed.includes('tx-packet=')) {
      const match = trimmed.match(/tx-packet=(\S+)/);
      if (match) {
        currentInterface.txPackets = match[1];
      }
    }
  }

  // Add last interface if exists
  if (currentInterface.name) {
    interfaces.push(currentInterface as InterfaceStatus);
  }

  return interfaces.filter(i => i.name && i.type);
}

/**
 * Get interface diagnostics from RouterOS
 */
export async function getInterfaceDiagnostics(client: SshClient): Promise<InterfaceStatus[]> {
  const output = await client.executeCommand('/interface print stats');

  return parseInterfaces(output);
}
