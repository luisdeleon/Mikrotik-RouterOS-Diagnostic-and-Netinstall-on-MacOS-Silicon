const fs = require('fs');
const path = require('path');

// Manually extracted router configurations from the WinBox file
const routerData = `
group=LUIS host=10.10.30.1 login=admin pwd=epson03_
group=MONSTER host=45.32.201.232 login=admin pwd=tercel23_
group=LUIS host=10.10.39.1 login=admin pwd=epson03_
group=WISP host=104.129.130.99 login=admin pwd=epson03_ note=KAMA DFW21
group=WISP host=138.128.244.228 login=admin pwd=epson03_ note=KAMA DFW00
group=WISP host=104.129.130.93 login=admin pwd=epson03_ note=KAMA DFW22
group=WISP host=104.129.131.145 login=admin pwd=Anabela2013$$$ note=KAMA DFW01
group=WIFILINK host=10.10.200.1 login=admin pwd=epson03_ note=BODEGA
group=LUIS host=home.ebluenet.com login=admin pwd=epson03_
group=SMARTWIFI host=186.96.167.66:8591 login=luisdeleon pwd=julien03
group=LAWNDALE host=6f4b05ae79c6.sn.mynetname.net login=admin pwd=epson03_
group=SARTEK host=hed08mqfnpn.sn.mynetname.net:9878 login=luis pwd=cisco2828
group=WISP host=138.128.244.228:9091 login=admin pwd=epson03_ note=TLAHUE - Jonna LHG
group=WISP host=138.128.244.228:9092 login=admin pwd=epson03_ note=TLAHUE - Jonna RB2011
group=SARTEK host=201.168.171.155:9878 login=luisdeleon pwd=cisco282
group=SARTEK host=187.188.202.178:9878 login=luisdeleon pwd=cisco2828
group=SARTEK host=916908810392.sn.mynetname.net:9878 login=luisdeleon pwd=cisco2828
group=SARTEK host=187.188.202.226:9878 login=luisdeleon pwd=cisco2828
group=WISP host=138.128.244.228:9191 login=luisdeleon pwd=julien03 note=TURBONET TAMAZOLAPA
group=WEBZY host=172.16.100.201 login=admin pwd=epson03_ note=UARANDY
group=MONSTER host=173.95.100.226 login=admin pwd=epson03_ note=Freeman Abe
group=MONSTER host=216.82.18.114 login=admin pwd=epson03_ note=Freeman Fay
group=WEBZY host=172.16.100.202 login=admin pwd=epson03_ note=UANORDAN
group=LUIS host=172.16.100.205 login=luisdeleon pwd=@Julien03 note=rb5009up-fosterwheeler
group=WIFILINK host=vpnpac.wifilink.mx login=luisdeleon pwd=Anabela2013$$$
group=PAC host=10.24.0.1 login=luisdeleon pwd=Anabela2013$$$
group=PAC host=10.24.8.1 login=luisdeleon pwd=Anabela2013$$$
group=PAC host=10.24.16.1 login=luisdeleon pwd=Anabela2013$$$
group=PAC host=10.24.24.1 login=luisdeleon pwd=Anabela2013$$$
group=PAC host=10.24.40.1 login=luisdeleon pwd=Anabela2013$$$
group=WISP host=138.128.244.228:9090 login=luisdeleon pwd=Anabela2013$$$ note=TLAHUE
group=WIFILINK host=172.16.16.102 login=luisdeleon pwd=Anabela2013$$$ note=GUADALUPE
group=WIFILINK host=172.16.16.103 login=luisdeleon pwd=Anabela2013$$$ note=HOME PAC
group=WIFILINK host=172.16.16.104 login=luisdeleon pwd=Anabela2013$$$ note=HOME LAX
group=WIFILINK host=172.16.16.106 login=luisdeleon pwd=Anabela2013$$$ note=TLAHUE
group=WIFILINK host=172.16.16.107 login=luisdeleon pwd=Anabela2013$$$ note=PIE LOMA
group=WIFILINK host=172.16.16.108 login=luisdeleon pwd=Anabela2013$$$ note=LA LOMA
group=WIFILINK host=172.16.16.109 login=luisdeleon pwd=Anabela2013$$$ note=PACHUQUILLA
group=WIFILINK host=172.16.16.105 login=luisdeleon pwd=Anabela2013$$$ note=DON CARLOS
group=WIFILINK host=62c046603d37ca2a.sn.mynetname.net:8297 login=luisdeleon pwd=Anabela2013$$$ note=DON CARLOS
group=PAC host=10.24.48.1 login=luisdeleon pwd=Anabela2013$$$
`;

const routers = [];
const lines = routerData.trim().split('\n').filter(l => l.trim());

for (const line of lines) {
  const router = {};

  // Extract group
  const groupMatch = line.match(/group=([^\s]+)/);
  const group = groupMatch ? groupMatch[1] : '';

  // Extract host and port
  const hostMatch = line.match(/host=([^\s]+)/);
  if (hostMatch) {
    const hostValue = hostMatch[1];
    if (hostValue.includes(':')) {
      const [host, port] = hostValue.split(':');
      router.host = host;
      router.port = parseInt(port, 10);
    } else {
      router.host = hostValue;
      router.port = 22;
    }
  }

  // Extract login
  const loginMatch = line.match(/login=([^\s]+)/);
  if (loginMatch) {
    router.username = loginMatch[1];
  }

  // Extract password
  const pwdMatch = line.match(/pwd=([^\s]+)/);
  if (pwdMatch) {
    router.password = pwdMatch[1];
  }

  // Extract note
  const noteMatch = line.match(/note=(.+?)(?:\s+group=|\s+host=|\s+login=|\s+pwd=|$)/);
  const note = noteMatch ? noteMatch[1].trim() : '';

  // Create name
  if (note) {
    router.name = `${group} - ${note}`;
  } else {
    router.name = `${group} - ${router.host}`;
  }

  // Only add if we have required fields
  if (router.host && router.username && router.password) {
    routers.push(router);
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

console.log(`✓ Imported ${routers.length} routers from WinBox configuration`);
console.log(`✓ Configuration written to: ${outputPath}\n`);

// Group routers by category
const groups = {};
config.routers.forEach(r => {
  const group = r.name.split(' - ')[0];
  if (!groups[group]) groups[group] = 0;
  groups[group]++;
});

console.log('Router counts by group:');
Object.entries(groups).sort((a, b) => b[1] - a[1]).forEach(([group, count]) => {
  console.log(`  ${group.padEnd(15)} ${count} router(s)`);
});
