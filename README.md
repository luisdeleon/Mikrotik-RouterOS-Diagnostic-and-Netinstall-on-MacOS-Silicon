# MikroTik RouterOS Diagnostic and Netinstall on macOS Silicon

[English](#english) | [Español](#español) | [Português](#português)

---

## English

### Overview

A comprehensive toolkit for MikroTik RouterOS management on macOS (especially Apple Silicon):

1. **Diagnostic Tools** - TypeScript CLI to monitor and optimize multiple RouterOS devices
2. **Netinstall for macOS** - Docker-based RouterOS installation tool for Apple Silicon Macs
3. **Auto-Optimization** - Automated performance tuning and security hardening

### Features

#### Diagnostic & Monitoring Tools
- 🔍 Run diagnostics on multiple routers concurrently
- 📊 System monitoring (CPU, memory, connections, uptime)
- 🌐 Interface statistics and WiFi diagnostics
- 🛡️ Security auditing (firewall, connection tracking, services)
- 🚀 Performance analysis and optimization recommendations
- 📝 Generate optimization scripts automatically
- 🔌 Support for SSH, VPN, and ZeroTier connections
- 🎯 Filter by router name or group
- 💻 Claude Code integration with slash commands

#### Netinstall for macOS Silicon
- 🍎 **Native ARM support** - Works on Apple Silicon Macs
- 🐳 **Docker-based** - No Wine, no Windows needed
- 🔧 **Automated** - DHCP/TFTP server handles everything
- 📦 **RouterOS 7.x support** - Install latest RouterOS versions
- 🖥️ **Interactive interface selection** - Choose the correct network adapter

### Quick Start

#### 1. Installation

```bash
# Clone the repository
git clone <repository-url>
cd RouterOs

# Install dependencies
npm install
```

#### 2. Configure Routers

```bash
# Option A: Copy and edit manually
cp routers.example.json routers.json
nano routers.json

# Option B: Import from WinBox addresses file
node parse-winbox-better.js
```

**Important:** `routers.json` is gitignored and contains your credentials.

#### 3. Run Diagnostics

```bash
# List all routers
npm run list

# Run full diagnostics
npm start

# Run diagnostics on specific router
npm start -- --router "Office Router - 192.168.1.1"

# Use Claude Code slash commands
/diagnose
/diagnose-router Office Router - 192.168.1.1
/system-check
```

#### 4. Auto-Optimize a Router

```bash
# Generate optimization package for a router
npm run optimize -- --router "Office Router - 192.168.1.1"

# This creates:
# - /ros/ROUTER-NAME/ROUTER-IP-optimization.rsc
# - Complete documentation and verification scripts
```

### Netinstall on macOS Silicon

#### Prerequisites
- macOS (Apple Silicon or Intel)
- Docker Desktop installed and running
- Ethernet cable connecting Mac to MikroTik router

#### Steps

1. **Navigate to Netinstall directory**
   ```bash
   cd docker-netinstall
   ```

2. **Run the automated script**
   ```bash
   ./netinstall.sh
   ```

3. **Select your network interface**
   - Script will show all interfaces with status
   - Choose the one connected to your router (usually en7 for USB docking)

4. **Put router in Netinstall mode**
   - Unplug power from router
   - Hold RESET button
   - Plug in power while holding RESET
   - Keep holding for 5-10 seconds
   - Release button (LED should blink rapidly)

5. **Wait for installation**
   - Watch the logs for DHCP requests and TFTP transfers
   - Installation takes 2-5 minutes
   - Router will reboot automatically

6. **Cleanup**
   ```bash
   ./cleanup.sh
   ```

See [docker-netinstall/README.md](./docker-netinstall/README.md) for detailed instructions.

### Claude Code Integration

Custom slash commands:
- `/diagnose` - Full diagnostics on all routers
- `/diagnose-router <name>` - Diagnose specific router
- `/diagnose-group <group>` - Diagnose router group
- `/list-routers` - List all configured routers
- `/system-check` - Quick system diagnostics
- `/interface-check` - Interface diagnostics
- `/routing-check` - Routing diagnostics

### Project Structure

```
RouterOs/
├── src/                      # TypeScript source code
├── ros/                      # Generated optimization scripts
│   └── ROUTER-NAME-IP/      # Per-router optimization packages
├── docker-netinstall/        # Netinstall for macOS
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── netinstall.sh        # Automated installation
│   ├── cleanup.sh
│   └── README.md
├── routers.json             # Your router credentials (gitignored)
├── routers.example.json     # Example configuration
├── package.json
└── README.md
```

### Security Notes

⚠️ **Important:**
- `routers.json` contains sensitive credentials and is automatically gitignored
- Never commit `routers.json` to version control
- Use SSH keys instead of passwords when possible
- Store credentials securely

### Requirements

- Node.js 18 or higher
- Docker Desktop (for Netinstall)
- SSH access to RouterOS devices
- RouterOS 6.x or 7.x
- macOS (for Netinstall features)

### Documentation

- [USAGE.md](./USAGE.md) - Detailed usage guide
- [AUTOMATION-GUIDE.md](./AUTOMATION-GUIDE.md) - Auto-optimization guide
- [docker-netinstall/README.md](./docker-netinstall/README.md) - Netinstall guide

---

## Español

### Descripción General

Un conjunto de herramientas completo para la gestión de MikroTik RouterOS en macOS (especialmente Apple Silicon):

1. **Herramientas de Diagnóstico** - CLI en TypeScript para monitorear y optimizar múltiples dispositivos RouterOS
2. **Netinstall para macOS** - Herramienta de instalación de RouterOS basada en Docker para Macs Apple Silicon
3. **Auto-Optimización** - Ajuste automático de rendimiento y refuerzo de seguridad

### Características

#### Herramientas de Diagnóstico y Monitoreo
- 🔍 Ejecutar diagnósticos en múltiples routers simultáneamente
- 📊 Monitoreo del sistema (CPU, memoria, conexiones, tiempo activo)
- 🌐 Estadísticas de interfaces y diagnósticos WiFi
- 🛡️ Auditoría de seguridad (firewall, seguimiento de conexiones, servicios)
- 🚀 Análisis de rendimiento y recomendaciones de optimización
- 📝 Generar scripts de optimización automáticamente
- 🔌 Soporte para conexiones SSH, VPN y ZeroTier
- 🎯 Filtrar por nombre de router o grupo
- 💻 Integración con Claude Code mediante comandos slash

#### Netinstall para macOS Silicon
- 🍎 **Soporte ARM nativo** - Funciona en Macs Apple Silicon
- 🐳 **Basado en Docker** - No requiere Wine ni Windows
- 🔧 **Automatizado** - El servidor DHCP/TFTP maneja todo
- 📦 **Soporte RouterOS 7.x** - Instala las últimas versiones de RouterOS
- 🖥️ **Selección interactiva de interfaz** - Elige el adaptador de red correcto

### Inicio Rápido

#### 1. Instalación

```bash
# Clonar el repositorio
git clone <url-repositorio>
cd RouterOs

# Instalar dependencias
npm install
```

#### 2. Configurar Routers

```bash
# Opción A: Copiar y editar manualmente
cp routers.example.json routers.json
nano routers.json

# Opción B: Importar desde archivo de direcciones WinBox
node parse-winbox-better.js
```

**Importante:** `routers.json` está en gitignore y contiene tus credenciales.

#### 3. Ejecutar Diagnósticos

```bash
# Listar todos los routers
npm run list

# Ejecutar diagnósticos completos
npm start

# Ejecutar diagnósticos en un router específico
npm start -- --router "Router Oficina - 192.168.1.1"

# Usar comandos slash de Claude Code
/diagnose
/diagnose-router Router Oficina - 192.168.1.1
/system-check
```

#### 4. Auto-Optimizar un Router

```bash
# Generar paquete de optimización para un router
npm run optimize -- --router "Router Oficina - 192.168.1.1"

# Esto crea:
# - /ros/NOMBRE-ROUTER/IP-ROUTER-optimization.rsc
# - Documentación completa y scripts de verificación
```

### Netinstall en macOS Silicon

#### Requisitos Previos
- macOS (Apple Silicon o Intel)
- Docker Desktop instalado y en ejecución
- Cable Ethernet conectando Mac al router MikroTik

#### Pasos

1. **Navegar al directorio Netinstall**
   ```bash
   cd docker-netinstall
   ```

2. **Ejecutar el script automatizado**
   ```bash
   ./netinstall.sh
   ```

3. **Seleccionar tu interfaz de red**
   - El script mostrará todas las interfaces con su estado
   - Elige la que está conectada a tu router (usualmente en7 para docking USB)

4. **Poner el router en modo Netinstall**
   - Desconectar alimentación del router
   - Mantener presionado el botón RESET
   - Conectar alimentación mientras mantienes RESET presionado
   - Mantener presionado por 5-10 segundos
   - Soltar el botón (el LED debería parpadear rápidamente)

5. **Esperar la instalación**
   - Observar los logs para peticiones DHCP y transferencias TFTP
   - La instalación toma 2-5 minutos
   - El router se reiniciará automáticamente

6. **Limpieza**
   ```bash
   ./cleanup.sh
   ```

Ver [docker-netinstall/README.md](./docker-netinstall/README.md) para instrucciones detalladas.

### Integración con Claude Code

Comandos slash personalizados:
- `/diagnose` - Diagnósticos completos en todos los routers
- `/diagnose-router <nombre>` - Diagnosticar router específico
- `/diagnose-group <grupo>` - Diagnosticar grupo de routers
- `/list-routers` - Listar todos los routers configurados
- `/system-check` - Diagnósticos rápidos del sistema
- `/interface-check` - Diagnósticos de interfaces
- `/routing-check` - Diagnósticos de enrutamiento

### Estructura del Proyecto

```
RouterOs/
├── src/                      # Código fuente TypeScript
├── ros/                      # Scripts de optimización generados
│   └── NOMBRE-ROUTER-IP/    # Paquetes de optimización por router
├── docker-netinstall/        # Netinstall para macOS
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── netinstall.sh        # Instalación automatizada
│   ├── cleanup.sh
│   └── README.md
├── routers.json             # Credenciales de tus routers (en gitignore)
├── routers.example.json     # Configuración de ejemplo
├── package.json
└── README.md
```

### Notas de Seguridad

⚠️ **Importante:**
- `routers.json` contiene credenciales sensibles y está automáticamente en gitignore
- Nunca hagas commit de `routers.json` al control de versiones
- Usa llaves SSH en lugar de contraseñas cuando sea posible
- Almacena las credenciales de forma segura

### Requisitos

- Node.js 18 o superior
- Docker Desktop (para Netinstall)
- Acceso SSH a dispositivos RouterOS
- RouterOS 6.x o 7.x
- macOS (para funciones de Netinstall)

### Documentación

- [USAGE.md](./USAGE.md) - Guía de uso detallada
- [AUTOMATION-GUIDE.md](./AUTOMATION-GUIDE.md) - Guía de auto-optimización
- [docker-netinstall/README.md](./docker-netinstall/README.md) - Guía de Netinstall

---

## Português

### Visão Geral

Um conjunto de ferramentas completo para gerenciamento de MikroTik RouterOS no macOS (especialmente Apple Silicon):

1. **Ferramentas de Diagnóstico** - CLI em TypeScript para monitorar e otimizar múltiplos dispositivos RouterOS
2. **Netinstall para macOS** - Ferramenta de instalação RouterOS baseada em Docker para Macs Apple Silicon
3. **Auto-Otimização** - Ajuste automático de desempenho e reforço de segurança

### Características

#### Ferramentas de Diagnóstico e Monitoramento
- 🔍 Executar diagnósticos em múltiplos roteadores simultaneamente
- 📊 Monitoramento do sistema (CPU, memória, conexões, tempo ativo)
- 🌐 Estatísticas de interfaces e diagnósticos WiFi
- 🛡️ Auditoria de segurança (firewall, rastreamento de conexões, serviços)
- 🚀 Análise de desempenho e recomendações de otimização
- 📝 Gerar scripts de otimização automaticamente
- 🔌 Suporte para conexões SSH, VPN e ZeroTier
- 🎯 Filtrar por nome de roteador ou grupo
- 💻 Integração com Claude Code através de comandos slash

#### Netinstall para macOS Silicon
- 🍎 **Suporte ARM nativo** - Funciona em Macs Apple Silicon
- 🐳 **Baseado em Docker** - Não requer Wine nem Windows
- 🔧 **Automatizado** - Servidor DHCP/TFTP cuida de tudo
- 📦 **Suporte RouterOS 7.x** - Instala versões mais recentes do RouterOS
- 🖥️ **Seleção interativa de interface** - Escolha o adaptador de rede correto

### Início Rápido

#### 1. Instalação

```bash
# Clonar o repositório
git clone <url-repositorio>
cd RouterOs

# Instalar dependências
npm install
```

#### 2. Configurar Roteadores

```bash
# Opção A: Copiar e editar manualmente
cp routers.example.json routers.json
nano routers.json

# Opção B: Importar do arquivo de endereços WinBox
node parse-winbox-better.js
```

**Importante:** `routers.json` está no gitignore e contém suas credenciais.

#### 3. Executar Diagnósticos

```bash
# Listar todos os roteadores
npm run list

# Executar diagnósticos completos
npm start

# Executar diagnósticos em roteador específico
npm start -- --router "Roteador Escritorio - 192.168.1.1"

# Usar comandos slash do Claude Code
/diagnose
/diagnose-router Roteador Escritorio - 192.168.1.1
/system-check
```

#### 4. Auto-Otimizar um Roteador

```bash
# Gerar pacote de otimização para um roteador
npm run optimize -- --router "Roteador Escritorio - 192.168.1.1"

# Isso cria:
# - /ros/NOME-ROTEADOR/IP-ROTEADOR-optimization.rsc
# - Documentação completa e scripts de verificação
```

### Netinstall no macOS Silicon

#### Pré-requisitos
- macOS (Apple Silicon ou Intel)
- Docker Desktop instalado e em execução
- Cabo Ethernet conectando Mac ao roteador MikroTik

#### Passos

1. **Navegar para o diretório Netinstall**
   ```bash
   cd docker-netinstall
   ```

2. **Executar o script automatizado**
   ```bash
   ./netinstall.sh
   ```

3. **Selecionar sua interface de rede**
   - O script mostrará todas as interfaces com seu status
   - Escolha a que está conectada ao seu roteador (geralmente en7 para docking USB)

4. **Colocar o roteador em modo Netinstall**
   - Desconectar alimentação do roteador
   - Manter pressionado o botão RESET
   - Conectar alimentação enquanto mantém RESET pressionado
   - Manter pressionado por 5-10 segundos
   - Soltar o botão (o LED deve piscar rapidamente)

5. **Aguardar a instalação**
   - Observar os logs para requisições DHCP e transferências TFTP
   - A instalação leva 2-5 minutos
   - O roteador reiniciará automaticamente

6. **Limpeza**
   ```bash
   ./cleanup.sh
   ```

Veja [docker-netinstall/README.md](./docker-netinstall/README.md) para instruções detalhadas.

### Integração com Claude Code

Comandos slash personalizados:
- `/diagnose` - Diagnósticos completos em todos os roteadores
- `/diagnose-router <nome>` - Diagnosticar roteador específico
- `/diagnose-group <grupo>` - Diagnosticar grupo de roteadores
- `/list-routers` - Listar todos os roteadores configurados
- `/system-check` - Diagnósticos rápidos do sistema
- `/interface-check` - Diagnósticos de interfaces
- `/routing-check` - Diagnósticos de roteamento

### Estrutura do Projeto

```
RouterOs/
├── src/                      # Código fonte TypeScript
├── ros/                      # Scripts de otimização gerados
│   └── NOME-ROTEADOR-IP/    # Pacotes de otimização por roteador
├── docker-netinstall/        # Netinstall para macOS
│   ├── Dockerfile
│   ├── entrypoint.sh
│   ├── netinstall.sh        # Instalação automatizada
│   ├── cleanup.sh
│   └── README.md
├── routers.json             # Credenciais dos seus roteadores (no gitignore)
├── routers.example.json     # Configuração de exemplo
├── package.json
└── README.md
```

### Notas de Segurança

⚠️ **Importante:**
- `routers.json` contém credenciais sensíveis e está automaticamente no gitignore
- Nunca faça commit do `routers.json` no controle de versão
- Use chaves SSH ao invés de senhas quando possível
- Armazene as credenciais de forma segura

### Requisitos

- Node.js 18 ou superior
- Docker Desktop (para Netinstall)
- Acesso SSH a dispositivos RouterOS
- RouterOS 6.x ou 7.x
- macOS (para recursos de Netinstall)

### Documentação

- [USAGE.md](./USAGE.md) - Guia de uso detalhado
- [AUTOMATION-GUIDE.md](./AUTOMATION-GUIDE.md) - Guia de auto-otimização
- [docker-netinstall/README.md](./docker-netinstall/README.md) - Guia de Netinstall

---

## License / Licencia / Licença

ISC

## Contributing / Contribuir

Contributions are welcome! Please feel free to submit a Pull Request.

¡Las contribuciones son bienvenidas! No dudes en enviar un Pull Request.

Contribuições são bem-vindas! Sinta-se à vontade para enviar um Pull Request.
