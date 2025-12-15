const fs = require('fs');
const path = require('path');

// Path to WinBox address file
const winboxFile = '/Users/luisdeleon/Library/CloudStorage/GoogleDrive-luis.deleon@ebluenet.com/My Drive/BackUps/addresses.wbx';

// Read the file
const content = fs.readFileSync(winboxFile, 'utf-8');

// Parse entries
const lines = content.split('\n');
const routers = [];

for (let i = 0; i < lines.length; i++) {
  const line = lines[i];

  // Look for lines with host information
  if (line.includes('host') && line.includes('login') && line.includes('pwd')) {
    const entry = {};

    // Extract host
    const hostMatch = line.match(/host([^\s]+)/);
    if (hostMatch) {
      const hostValue = hostMatch[1];
      // Split host and port if present
      if (hostValue.includes(':')) {
        const [host, port] = hostValue.split(':');
        entry.host = host;
        entry.port = parseInt(port, 10);
      } else {
        entry.host = hostValue;
        entry.port = 22;
      }
    }

    // Extract login
    const loginMatch = line.match(/login([^\s]+)/);
    if (loginMatch) {
      entry.username = loginMatch[1];
    }

    // Extract password
    const pwdMatch = line.match(/pwd([^\s]+)/);
    if (pwdMatch) {
      entry.password = pwdMatch[1];
    }

    // Extract note (description)
    const noteMatch = line.match(/note([^\s]*)/);
    let note = '';
    if (noteMatch) {
      note = noteMatch[1];
    }

    // Extract group
    const groupMatch = line.match(/group([^\s]+)/);
    let group = '';
    if (groupMatch) {
      group = groupMatch[1];
    }

    // Create a meaningful name
    if (note) {
      entry.name = note;
    } else if (group) {
      entry.name = `${group} - ${entry.host}`;
    } else {
      entry.name = entry.host;
    }

    // Add group as prefix if both exist
    if (group && note) {
      entry.name = `${group} - ${note}`;
    }

    // Only add if we have required fields
    if (entry.host && entry.username && entry.password) {
      routers.push(entry);
    }
  }
}

// Create the configuration object
const config = {
  routers: routers.map(r => ({
    name: r.name,
    host: r.host,
    port: r.port || 22,
    username: r.username,
    password: r.password
  }))
};

// Write to routers.json
const outputPath = path.join(__dirname, 'routers.json');
fs.writeFileSync(outputPath, JSON.stringify(config, null, 2));

console.log(`✓ Parsed ${routers.length} routers from WinBox addresses`);
console.log(`✓ Configuration written to: ${outputPath}`);
console.log('\nFirst 5 routers:');
config.routers.slice(0, 5).forEach(r => {
  console.log(`  - ${r.name} (${r.host}:${r.port})`);
});
