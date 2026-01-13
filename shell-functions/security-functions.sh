#!/usr/bin/env bash

# Security and auditing shell functions
# A collection of functions for security checks and system auditing

#######################################
# Check for world-writable files
# Arguments:
#   Directory path (default: current directory)
# Returns:
#   List of world-writable files
#######################################
function FindWorldWritable() {
  local _dir="${1:-.}"

  echo "World-writable files in $_dir:"
  find "$_dir" -type f -perm -002 2>/dev/null
}

#######################################
# Check for SUID/SGID files
# Arguments:
#   Directory path (default: /usr/bin and /usr/sbin)
# Returns:
#   List of SUID/SGID files
#######################################
function FindSUID() {
  local _dir="${1:-/usr}"

  echo "SUID/SGID files in $_dir:"
  find "$_dir" -type f \( -perm -4000 -o -perm -2000 \) -ls 2>/dev/null
}

#######################################
# Check for files without owner
# Arguments:
#   Directory path (default: /)
# Returns:
#   List of orphaned files
#######################################
function FindOrphaned() {
  local _dir="${1:-/}"

  echo "Files without valid owner in $_dir:"
  find "$_dir" -nouser -o -nogroup 2>/dev/null
}

#######################################
# Audit listening ports and services
# Returns:
#   List of listening ports with services
#######################################
function AuditPorts() {
  echo "=== Listening Ports Audit ==="
  
  if command -v ss &> /dev/null; then
    ss -tlnp 2>/dev/null | awk 'NR>1 {printf "Port: %-20s Process: %s\n", $4, $7}'
  elif command -v netstat &> /dev/null; then
    netstat -tlnp 2>/dev/null | awk 'NR>2 {printf "Port: %-20s Process: %s\n", $4, $7}'
  else
    echo "Neither 'ss' nor 'netstat' available"
    return 1
  fi
}

#######################################
# Check for failed login attempts
# Dependencies: lastb (requires root)
# Returns:
#   Recent failed login attempts
#######################################
function CheckFailedLogins() {
  if [[ $EUID -ne 0 ]]; then
    echo "Warning: This function requires root privileges for full access"
  fi

  echo "=== Failed Login Attempts ==="
  lastb | head -20
}

#######################################
# Audit user accounts
# Returns:
#   List of user accounts with UID >= 1000
#######################################
function AuditUsers() {
  echo "=== Regular User Accounts ==="
  awk -F: '$3 >= 1000 && $1 != "nobody" {print $1 " (UID:" $3 ")"}' /etc/passwd
  
  echo -e "\n=== Users with UID 0 (root privileges) ==="
  awk -F: '$3 == 0 {print $1}' /etc/passwd
}

#######################################
# Check for empty password fields
# Returns:
#   Users with empty passwords
#######################################
function CheckEmptyPasswords() {
  if [[ $EUID -ne 0 ]]; then
    echo "Error: This function requires root privileges"
    return 1
  fi

  echo "Users with empty passwords:"
  awk -F: '($2 == "" || $2 == "!") {print $1}' /etc/shadow
}

#######################################
# Check file permissions on sensitive files
# Returns:
#   Permission audit of sensitive files
#######################################
function AuditSensitiveFiles() {
  echo "=== Sensitive File Permissions ==="
  
  local _files=(
    "/etc/passwd"
    "/etc/shadow"
    "/etc/group"
    "/etc/gshadow"
    "/etc/sudoers"
    "/root/.ssh/authorized_keys"
    "/etc/ssh/sshd_config"
  )

  for file in "${_files[@]}"; do
    if [[ -f "$file" ]]; then
      ls -l "$file"
    else
      echo "$file: Not found"
    fi
  done
}

#######################################
# Check SSH configuration security
# Returns:
#   SSH security settings
#######################################
function AuditSSH() {
  local _sshd_config="/etc/ssh/sshd_config"

  if [[ ! -f "$_sshd_config" ]]; then
    echo "SSH config not found"
    return 1
  fi

  echo "=== SSH Security Audit ==="
  echo "PermitRootLogin: $(grep "^PermitRootLogin" "$_sshd_config" || echo "Not set (default: yes)")"
  echo "PasswordAuthentication: $(grep "^PasswordAuthentication" "$_sshd_config" || echo "Not set (default: yes)")"
  echo "PubkeyAuthentication: $(grep "^PubkeyAuthentication" "$_sshd_config" || echo "Not set (default: yes)")"
  echo "PermitEmptyPasswords: $(grep "^PermitEmptyPasswords" "$_sshd_config" || echo "Not set (default: no)")"
  echo "X11Forwarding: $(grep "^X11Forwarding" "$_sshd_config" || echo "Not set")"
  echo "Protocol: $(grep "^Protocol" "$_sshd_config" || echo "Not set (should be 2)")"
}

#######################################
# Scan for open ports on localhost
# Returns:
#   List of open ports
#######################################
function ScanLocalPorts() {
  echo "Scanning localhost ports 1-1024..."
  
  for port in {1..1024}; do
    (echo >/dev/tcp/localhost/$port) &>/dev/null && echo "Port $port is open"
  done
}

#######################################
# Check firewall status
# Returns:
#   Firewall rules and status
#######################################
function CheckFirewall() {
  echo "=== Firewall Status ==="
  
  if command -v ufw &> /dev/null; then
    echo "UFW Status:"
    sudo ufw status verbose
  elif command -v firewall-cmd &> /dev/null; then
    echo "Firewalld Status:"
    sudo firewall-cmd --state
    sudo firewall-cmd --list-all
  elif command -v iptables &> /dev/null; then
    echo "IPTables Rules:"
    sudo iptables -L -n -v
  else
    echo "No firewall tool found"
  fi
}

#######################################
# Check for rootkit indicators (basic)
# Returns:
#   Basic rootkit checks
#######################################
function CheckRootkit() {
  echo "=== Basic Rootkit Checks ==="
  
  echo "Checking for suspicious files in /tmp:"
  find /tmp -type f -name ".*" 2>/dev/null
  
  echo -e "\nChecking for suspicious processes:"
  ps aux | grep -E '\[.*\]' | grep -v grep
  
  echo -e "\nChecking loaded kernel modules:"
  lsmod | head -20
  
  echo -e "\nNote: Use tools like rkhunter or chkrootkit for comprehensive checks"
}

#######################################
# Check system logs for suspicious activity
# Returns:
#   Summary of suspicious log entries
#######################################
function CheckSuspiciousActivity() {
  echo "=== Suspicious Activity Check ==="
  
  if [[ -f /var/log/auth.log ]]; then
    echo "Failed sudo attempts:"
    grep "sudo.*FAILED" /var/log/auth.log | tail -10
    
    echo -e "\nRecent SSH login attempts:"
    grep "sshd.*Failed" /var/log/auth.log | tail -10
  elif [[ -f /var/log/secure ]]; then
    echo "Failed sudo attempts:"
    grep "sudo.*FAILED" /var/log/secure | tail -10
    
    echo -e "\nRecent SSH login attempts:"
    grep "sshd.*Failed" /var/log/secure | tail -10
  else
    echo "Auth log not found"
  fi
}

#######################################
# Generate security report
# Returns:
#   Comprehensive security summary
#######################################
function SecurityReport() {
  echo "========================================="
  echo "       SYSTEM SECURITY REPORT"
  echo "       Generated: $(date)"
  echo "========================================="
  echo ""
  
  AuditUsers
  echo ""
  AuditSensitiveFiles
  echo ""
  AuditPorts
  echo ""
  AuditSSH
  echo ""
  
  echo "========================================="
  echo "            END OF REPORT"
  echo "========================================="
}
