/**
 * Router configuration interface
 */
export interface RouterConfig {
  name: string;
  host: string;
  port: number;
  username: string;
  password: string;
}

/**
 * Configuration file structure
 */
export interface Config {
  routers: RouterConfig[];
}

/**
 * System resource information
 */
export interface SystemResource {
  uptime: string;
  version: string;
  cpu: string;
  cpuLoad: string;
  freeMemory: string;
  totalMemory: string;
  architecture: string;
  boardName: string;
}

/**
 * Interface status information
 */
export interface InterfaceStatus {
  name: string;
  type: string;
  running: boolean;
  disabled: boolean;
  rxBytes?: string;
  txBytes?: string;
  rxPackets?: string;
  txPackets?: string;
}

/**
 * Route information
 */
export interface RouteInfo {
  dstAddress: string;
  gateway: string;
  distance: string;
  scope: string;
  targetScope?: string;
}

/**
 * Firewall statistics
 */
export interface FirewallStats {
  filterRules: number;
  natRules: number;
}

/**
 * BGP peer information
 */
export interface BgpPeer {
  name: string;
  remote: string;
  state: string;
  uptime?: string;
}

/**
 * OSPF neighbor information
 */
export interface OspfNeighbor {
  routerId: string;
  address: string;
  state: string;
  priority?: string;
}

/**
 * Diagnostic results for a single router
 */
export interface DiagnosticResults {
  router: RouterConfig;
  connected: boolean;
  error?: string;
  system?: SystemResource;
  interfaces?: InterfaceStatus[];
  routes?: RouteInfo[];
  firewall?: FirewallStats;
  bgpPeers?: BgpPeer[];
  ospfNeighbors?: OspfNeighbor[];
  timestamp: Date;
}

/**
 * CLI options
 */
export interface CliOptions {
  router?: string;
  category?: 'system' | 'interfaces' | 'routing' | 'all';
  config?: string;
}

/**
 * Diagnostic category type
 */
export type DiagnosticCategory = 'system' | 'interfaces' | 'routing';
