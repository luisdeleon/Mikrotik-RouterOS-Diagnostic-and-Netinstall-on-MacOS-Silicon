import { SshClient } from '../ssh-client.js';
import { RouteInfo, FirewallStats, BgpPeer, OspfNeighbor } from '../types.js';

/**
 * Parse route output from RouterOS
 */
function parseRoutes(output: string): RouteInfo[] {
  const routes: RouteInfo[] = [];
  const lines = output.split('\n');

  for (const line of lines) {
    const trimmed = line.trim();

    // Skip headers and empty lines
    if (!trimmed || trimmed.startsWith('Flags:') || trimmed.startsWith('#')) {
      continue;
    }

    const route: Partial<RouteInfo> = {};

    if (trimmed.includes('dst-address=')) {
      const match = trimmed.match(/dst-address=(\S+)/);
      if (match) {
        route.dstAddress = match[1];
      }
    }
    if (trimmed.includes('gateway=')) {
      const match = trimmed.match(/gateway=(\S+)/);
      if (match) {
        route.gateway = match[1];
      }
    }
    if (trimmed.includes('distance=')) {
      const match = trimmed.match(/distance=(\S+)/);
      if (match) {
        route.distance = match[1];
      }
    }
    if (trimmed.includes('scope=')) {
      const match = trimmed.match(/scope=(\S+)/);
      if (match) {
        route.scope = match[1];
      }
    }

    if (route.dstAddress && route.gateway) {
      routes.push(route as RouteInfo);
    }
  }

  return routes;
}

/**
 * Parse firewall count output
 */
function parseFirewallCount(output: string): number {
  const match = output.match(/(\d+)/);
  return match ? parseInt(match[1], 10) : 0;
}

/**
 * Parse BGP peers
 */
function parseBgpPeers(output: string): BgpPeer[] {
  const peers: BgpPeer[] = [];
  const lines = output.split('\n');

  let currentPeer: Partial<BgpPeer> = {};

  for (const line of lines) {
    const trimmed = line.trim();

    if (!trimmed || trimmed.startsWith('Flags:') || trimmed.startsWith('#')) {
      if (currentPeer.name && currentPeer.remote) {
        peers.push(currentPeer as BgpPeer);
        currentPeer = {};
      }
      continue;
    }

    if (trimmed.includes('name=')) {
      const match = trimmed.match(/name="?([^"]+)"?/);
      if (match) {
        currentPeer.name = match[1];
      }
    }
    if (trimmed.includes('remote-address=')) {
      const match = trimmed.match(/remote-address=(\S+)/);
      if (match) {
        currentPeer.remote = match[1];
      }
    }
    if (trimmed.includes('state=')) {
      const match = trimmed.match(/state=(\S+)/);
      if (match) {
        currentPeer.state = match[1];
      }
    }
    if (trimmed.includes('uptime=')) {
      const match = trimmed.match(/uptime=(\S+)/);
      if (match) {
        currentPeer.uptime = match[1];
      }
    }
  }

  if (currentPeer.name && currentPeer.remote) {
    peers.push(currentPeer as BgpPeer);
  }

  return peers;
}

/**
 * Parse OSPF neighbors
 */
function parseOspfNeighbors(output: string): OspfNeighbor[] {
  const neighbors: OspfNeighbor[] = [];
  const lines = output.split('\n');

  let currentNeighbor: Partial<OspfNeighbor> = {};

  for (const line of lines) {
    const trimmed = line.trim();

    if (!trimmed || trimmed.startsWith('Flags:') || trimmed.startsWith('#')) {
      if (currentNeighbor.routerId && currentNeighbor.address) {
        neighbors.push(currentNeighbor as OspfNeighbor);
        currentNeighbor = {};
      }
      continue;
    }

    if (trimmed.includes('router-id=')) {
      const match = trimmed.match(/router-id=(\S+)/);
      if (match) {
        currentNeighbor.routerId = match[1];
      }
    }
    if (trimmed.includes('address=')) {
      const match = trimmed.match(/address=(\S+)/);
      if (match) {
        currentNeighbor.address = match[1];
      }
    }
    if (trimmed.includes('state=')) {
      const match = trimmed.match(/state="?([^"]+)"?/);
      if (match) {
        currentNeighbor.state = match[1];
      }
    }
    if (trimmed.includes('priority=')) {
      const match = trimmed.match(/priority=(\S+)/);
      if (match) {
        currentNeighbor.priority = match[1];
      }
    }
  }

  if (currentNeighbor.routerId && currentNeighbor.address) {
    neighbors.push(currentNeighbor as OspfNeighbor);
  }

  return neighbors;
}

/**
 * Get routing diagnostics from RouterOS
 */
export async function getRoutingDiagnostics(client: SshClient): Promise<{
  routes: RouteInfo[];
  firewall: FirewallStats;
  bgpPeers: BgpPeer[];
  ospfNeighbors: OspfNeighbor[];
}> {
  const commands = [
    '/ip route print detail',
    '/ip firewall filter print count-only',
    '/ip firewall nat print count-only',
  ];

  const results = await client.executeCommands(commands);

  let routes: RouteInfo[] = [];
  let filterCount = 0;
  let natCount = 0;
  let bgpPeers: BgpPeer[] = [];
  let ospfNeighbors: OspfNeighbor[] = [];

  for (const [command, output] of results) {
    if (command.includes('route')) {
      routes = parseRoutes(output);
    } else if (command.includes('filter')) {
      filterCount = parseFirewallCount(output);
    } else if (command.includes('nat')) {
      natCount = parseFirewallCount(output);
    }
  }

  // Try to get BGP peers (may not exist on all routers)
  try {
    const bgpOutput = await client.executeCommand('/routing bgp peer print detail');
    bgpPeers = parseBgpPeers(bgpOutput);
  } catch (error) {
    // BGP not configured, ignore
  }

  // Try to get OSPF neighbors (may not exist on all routers)
  try {
    const ospfOutput = await client.executeCommand('/routing ospf neighbor print detail');
    ospfNeighbors = parseOspfNeighbors(ospfOutput);
  } catch (error) {
    // OSPF not configured, ignore
  }

  return {
    routes,
    firewall: {
      filterRules: filterCount,
      natRules: natCount,
    },
    bgpPeers,
    ospfNeighbors,
  };
}
