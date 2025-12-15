################################################################################
# BACKUP SCRIPT - Run This First!
# Router: pachome-hapac2 - 10.10.39.2
################################################################################
# This script creates a complete backup of your router configuration
# before applying any optimizations.
#
# USAGE:
#   1. Upload this file to your router
#   2. Run: /import BACKUP-FIRST.rsc
#   3. Download the backup file to your computer
#   4. Then run the optimization script
################################################################################

:log info "=========================================="
:log info "CREATING BACKUP"
:log info "=========================================="

# Get current date/time for backup filename
:local dateTime [/system clock get date]
:local timeNow [/system clock get time]
:local backupName "backup-pachome-hapac2-10.10.39.2-$dateTime-$timeNow"

:log info "Creating configuration export..."

# Export full configuration
/export file=$backupName

:log info "Backup created: $backupName.rsc"

# Also create binary backup (includes user manager database, etc.)
:log info "Creating binary backup..."
/system backup save name=$backupName

:log info "Binary backup created: $backupName.backup"

:log info "=========================================="
:log info "BACKUP COMPLETED!"
:log info "=========================================="
:log info "Files created:"
:log info "  1. $backupName.rsc (text config)"
:log info "  2. $backupName.backup (binary backup)"
:log info "=========================================="
:log info "NEXT STEPS:"
:log info "  1. Download both backup files to your computer"
:log info "     Via WinBox: Files menu > Download"
:log info "     Via SCP: scp admin@10.10.39.2:$backupName.* ."
:log info "  2. Store backups in safe location"
:log info "  3. Now you can safely run optimization script"
:log info "=========================================="

# List backup files
:delay 2s
:log info "Backup files on router:"
/file print detail where name~"backup-pachome"
