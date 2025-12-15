################################################################################
# BACKUP SCRIPT - EXAMPLE ROUTER
# Always create a backup before making changes!
################################################################################

:log info "Creating backup for EXAMPLE-192.168.88.1..."

# Create timestamped backup
:local timestamp [/system clock get date]
:local backupname ("backup-" . $timestamp)

# Export text configuration
:log info "Exporting configuration..."
/export file=$backupname

# Create binary backup
:log info "Creating binary backup..."
/system backup save name=$backupname

:log info "✓ Backup created:"
:log info "  - Text config: $backupname.rsc"
:log info "  - Binary backup: $backupname.backup"

:put "✓ Backup completed successfully!"
:put "Files created:"
:put "  - $backupname.rsc (text configuration)"
:put "  - $backupname.backup (binary backup)"
:put ""
:put "Download these files before proceeding with optimization!"
