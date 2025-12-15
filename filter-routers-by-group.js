#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Get group name from command line
const groupName = process.argv[2];

if (!groupName) {
  console.error('Usage: node filter-routers-by-group.js <GROUP_NAME>');
  console.error('\nAvailable groups: WIFILINK, WISP, PAC, SARTEK, LUIS, MONSTER, WEBZY, SMARTWIFI, LAWNDALE');
  process.exit(1);
}

// Read routers.json
const configPath = path.join(__dirname, 'routers.json');
const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));

// Filter routers by group
const filteredRouters = config.routers.filter(router =>
  router.name.toUpperCase().startsWith(groupName.toUpperCase())
);

if (filteredRouters.length === 0) {
  console.error(`No routers found in group: ${groupName}`);
  process.exit(1);
}

// Create temporary config
const tempConfig = {
  routers: filteredRouters
};

const tempPath = path.join(__dirname, 'routers-temp.json');
fs.writeFileSync(tempPath, JSON.stringify(tempConfig, null, 2));

console.log(`✓ Created temporary config with ${filteredRouters.length} router(s) from ${groupName} group`);
console.log(`✓ Config saved to: routers-temp.json`);
console.log('\nRouters in this group:');
filteredRouters.forEach(r => {
  console.log(`  - ${r.name} (${r.host}:${r.port})`);
});
console.log(`\nRun diagnostics with: npm start -- --config routers-temp.json`);
