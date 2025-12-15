---
description: Run system diagnostics only (CPU, memory, uptime, version)
---

Run system diagnostics on all routers. This will check:
- RouterOS version
- Hardware information (board name, architecture)
- CPU usage and type
- Memory usage (free/total)
- System uptime

Execute: `npm start -- --category system`

This is faster than full diagnostics and useful for quick health checks.
