import { SshClient } from '../ssh-client.js';
import { RouterConfig, DiagnosticResults, DiagnosticCategory } from '../types.js';
import { getSystemDiagnostics } from './system.js';
import { getInterfaceDiagnostics } from './interfaces.js';
import { getRoutingDiagnostics } from './routing.js';

/**
 * Run diagnostics on a single router
 */
export async function runDiagnostics(
  router: RouterConfig,
  categories: DiagnosticCategory[] = ['system', 'interfaces', 'routing']
): Promise<DiagnosticResults> {
  const result: DiagnosticResults = {
    router,
    connected: false,
    timestamp: new Date(),
  };

  const client = new SshClient(router);

  try {
    // Connect to router
    await client.connect();
    result.connected = true;

    // Run requested diagnostics
    for (const category of categories) {
      switch (category) {
        case 'system':
          result.system = await getSystemDiagnostics(client);
          break;

        case 'interfaces':
          result.interfaces = await getInterfaceDiagnostics(client);
          break;

        case 'routing':
          const routingData = await getRoutingDiagnostics(client);
          result.routes = routingData.routes;
          result.firewall = routingData.firewall;
          result.bgpPeers = routingData.bgpPeers;
          result.ospfNeighbors = routingData.ospfNeighbors;
          break;
      }
    }
  } catch (error) {
    result.error = error instanceof Error ? error.message : String(error);
  } finally {
    client.disconnect();
  }

  return result;
}

/**
 * Run diagnostics on multiple routers concurrently
 */
export async function runDiagnosticsOnRouters(
  routers: RouterConfig[],
  categories: DiagnosticCategory[] = ['system', 'interfaces', 'routing']
): Promise<DiagnosticResults[]> {
  const promises = routers.map((router) => runDiagnostics(router, categories));
  return Promise.all(promises);
}
