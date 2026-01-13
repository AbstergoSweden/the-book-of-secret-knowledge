# Shell Functions Collection

A comprehensive collection of useful shell functions for system administration, network operations, file management, development workflows, and security auditing.

## Table of Contents

1. [Network Functions](#network-functions)
2. [System Functions](#system-functions)
3. [File Functions](#file-functions)
4. [Git Functions](#git-functions)
5. [Docker Functions](#docker-functions)
6. [Security Functions](#security-functions)

## Installation

To use these functions, source the desired file in your `.bashrc` or `.zshrc`:

```bash
# Source all functions
for file in ~/the-book-of-secret-knowledge/shell-functions/*.sh; do
  source "$file"
done

# Or source individual files
source ~/the-book-of-secret-knowledge/shell-functions/network-functions.sh
source ~/the-book-of-secret-knowledge/shell-functions/system-functions.sh
```

Alternatively, you can source them temporarily in your current shell:

```bash
source shell-functions/network-functions.sh
```

## Network Functions

Functions for network diagnostics, DNS lookups, and connectivity testing.

**File:** `network-functions.sh`

### Available Functions

- `DomainResolve <domain>` - Resolve domain to IP using DNS over HTTPS
- `GetASN <ip>` - Get Autonomous System Number for an IP address
- `CheckPort <host> <port>` - Check if a port is open on a host
- `GetPublicIP` - Get your public IP address
- `GetLocalIP` - Get local IP addresses
- `PingSweep <subnet>` - Scan a subnet for active hosts (e.g., 192.168.1)
- `CheckHTTP <url>` - Check HTTP/HTTPS response code
- `ListOpenPorts` - List open ports on local machine
- `DNSLookup <domain>` - DNS lookup with multiple record types

### Examples

```bash
DomainResolve google.com
# google.com > 142.250.185.46

GetASN 1.1.1.1
# 1.1.1.1 > AS13335 Cloudflare, Inc.

CheckPort google.com 443
# Port 443 on google.com is OPEN

GetPublicIP
# Public IP: 203.0.113.42

CheckHTTP https://www.google.com
# HTTP Status Code for https://www.google.com: 200
# ✓ OK
```

## System Functions

Functions for system monitoring, process management, and resource analysis.

**File:** `system-functions.sh`

### Available Functions

- `CheckService <service>` - Check if a service is running
- `FindProcess <pattern>` - Find processes by name
- `ProcessMemory <process>` - Get memory usage of a process
- `TopMemory` - Show top 10 memory consuming processes
- `TopCPU` - Show top 10 CPU consuming processes
- `DiskUsage` - Show disk usage summary
- `LargestDirs [path] [count]` - Find largest directories
- `LargestFiles [path] [count]` - Find largest files
- `SysInfo` - System information summary
- `CheckLoad [threshold]` - Check system load and alert if high
- `MonitorLog <logfile> [pattern]` - Monitor a log file in real-time
- `QuickBackup <file>` - Quick backup of a file with timestamp
- `CheckZombies` - Check for zombie processes
- `ShowUsers` - Show logged in users
- `CheckInodes` - Check available disk inodes

### Examples

```bash
CheckService nginx
# Service 'nginx' is RUNNING

TopMemory
# Top 10 processes by memory usage

SysInfo
# === System Information ===
# Hostname: server01
# Kernel: 5.15.0-56-generic
# ...

LargestDirs /var/log 5
# Top 5 largest directories in /var/log
```

## File Functions

Functions for file operations, searching, and management.

**File:** `file-functions.sh`

### Available Functions

- `FindDuplicates [directory]` - Find duplicate files by content (MD5)
- `FindModified <days> [directory]` - Find files modified in the last N days
- `FindLarge <size> [directory]` - Find files larger than specified size
- `BulkRename <search> <replace> [directory]` - Bulk rename files with pattern
- `ArchiveDir <directory>` - Archive directory with timestamp
- `Extract <archive>` - Extract various archive formats
- `FindEmptyDirs [directory]` - Find empty directories
- `FindBrokenLinks [directory]` - Find broken symbolic links
- `CountByExtension [directory]` - Count files by extension
- `MkdirCD <directory>` - Create directory and change into it
- `DirSize [directory]` - Calculate directory size
- `GrepFiles <pattern> [directory]` - Find files containing text pattern
- `CompareDirs <dir1> <dir2>` - Compare two directories
- `SafeDelete <target>` - Safe file deletion (move to trash)

### Examples

```bash
FindLarge 100M /var
# Files larger than 100M in /var

BulkRename "old" "new" ./images
# Renaming files in ./images (replacing 'old' with 'new')

Extract myarchive.tar.gz
# Successfully extracted: myarchive.tar.gz

MkdirCD project/src
# Created and changed to: /home/user/project/src
```

## Git Functions

Helper functions for common Git operations and workflows.

**File:** `git-functions.sh`

### Available Functions

- `gs` - Git status with short format
- `glog [count]` - Git log with pretty format
- `GitLastChanged` - Show changed files in last commit
- `GitNewBranch <name>` - Create and checkout a new branch
- `GitDeleteBranch <name>` - Delete local and remote branch
- `GitUndoCommit` - Undo last commit (keep changes)
- `GitAmend` - Amend last commit with current changes
- `GitFileHistory <file>` - Show file history
- `GitBranches` - Show branches sorted by last commit date
- `GitFindCommit <pattern>` - Find commits by message
- `GitStats` - Show repository statistics
- `GitCleanup` - Clean up merged branches
- `GitAlias <name> <command>` - Create a git alias
- `GitChangesSize` - Show uncommitted changes size

### Examples

```bash
gs
# ## main...origin/main
# M README.md

glog 5
# * a1b2c3d (HEAD -> main) Update documentation
# * e4f5g6h Add new feature
# ...

GitNewBranch feature/new-api
# Switched to a new branch 'feature/new-api'

GitStats
# === Repository Statistics ===
# Total commits: 1234
# Total contributors: 42
```

## Docker Functions

Helper functions for Docker container and image management.

**File:** `docker-functions.sh`

### Available Functions

- `DockerStopAll` - Stop all running containers
- `DockerClean` - Remove all stopped containers and unused resources
- `DockerStats` - Show container resource usage
- `DockerShell <container>` - Get shell access to container
- `DockerLogs <container> [lines]` - Show container logs with tail
- `DockerImages` - List images sorted by size
- `DockerCleanDangling` - Remove dangling images
- `DockerDiskUsage` - Show Docker disk usage
- `DockerBackup <container> <volume> [dest]` - Backup container data volume
- `DockerWatch` - Monitor Docker events
- `DockerIPs` - List all container IPs
- `DockerDiff <image1> <image2>` - Compare two images
- `DockerInfo <container>` - Get container inspect information
- `DockerExport <container> <image>` - Export container to image

### Examples

```bash
DockerStats
# NAME        CPU %    MEM USAGE       NET I/O
# webapp      2.5%     512MB/2GB      1.2MB/890KB

DockerShell webapp
# root@abc123:/app#

DockerClean
# Removing stopped containers...
# Cleanup complete
```

## Security Functions

Functions for security auditing and system hardening checks.

**File:** `security-functions.sh`

### Available Functions

- `FindWorldWritable [directory]` - Check for world-writable files
- `FindSUID [directory]` - Check for SUID/SGID files
- `FindOrphaned [directory]` - Check for files without owner
- `AuditPorts` - Audit listening ports and services
- `CheckFailedLogins` - Check for failed login attempts
- `AuditUsers` - Audit user accounts
- `CheckEmptyPasswords` - Check for empty password fields (requires root)
- `AuditSensitiveFiles` - Check file permissions on sensitive files
- `AuditSSH` - Check SSH configuration security
- `ScanLocalPorts` - Scan for open ports on localhost
- `CheckFirewall` - Check firewall status
- `CheckRootkit` - Check for rootkit indicators (basic)
- `CheckSuspiciousActivity` - Check system logs for suspicious activity
- `SecurityReport` - Generate security report

### Examples

```bash
AuditPorts
# === Listening Ports Audit ===
# Port: 0.0.0.0:22        Process: sshd
# Port: 0.0.0.0:80        Process: nginx

AuditSSH
# === SSH Security Audit ===
# PermitRootLogin: no
# PasswordAuthentication: yes
# ...

SecurityReport
# =========================================
#        SYSTEM SECURITY REPORT
# =========================================
```

## Dependencies

Most functions use standard Unix/Linux utilities. Some functions have specific dependencies:

- **curl** - Required for network functions (DomainResolve, GetPublicIP, etc.)
- **jq** - Required for JSON parsing in some functions
- **nc (netcat)** - Optional for port checking
- **dig/nslookup** - For DNS lookups
- **docker** - Required for Docker functions
- **git** - Required for Git functions
- **md5sum** - For finding duplicate files

## Contributing

Feel free to add more useful functions! Follow these guidelines:

1. Add comprehensive comments explaining what the function does
2. Include usage examples
3. Handle errors gracefully
4. Check for required dependencies
5. Use clear, descriptive function names

## License

MIT License - See main repository LICENSE.md
