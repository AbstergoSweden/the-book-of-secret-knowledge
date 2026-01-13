#!/usr/bin/env bash

# Network-related shell functions
# A collection of useful network utility functions

#######################################
# Domain resolve - Resolve domain to IP using DNS over HTTPS
# Dependencies: curl, jq
# Arguments:
#   Domain name to resolve
# Returns:
#   IP address or error message
#######################################
function DomainResolve() {
  local _host="$1"
  local _curl_base="curl --request GET"
  local _timeout="15"

  _host_ip=$($_curl_base -ks -m "$_timeout" "https://dns.google.com/resolve?name=${_host}&type=A" | \
  jq '.Answer[0].data' | tr -d "\"" 2>/dev/null)

  if [[ -z "$_host_ip" ]] || [[ "$_host_ip" == "null" ]] ; then
    echo -en "Unsuccessful domain name resolution.\\n"
  else
    echo -en "$_host > $_host_ip\\n"
  fi
}

#######################################
# Get ASN - Get Autonomous System Number for an IP
# Dependencies: curl
# Arguments:
#   IP address to lookup
# Returns:
#   ASN information or error message
#######################################
function GetASN() {
  local _ip="$1"
  local _curl_base="curl --request GET"
  local _timeout="15"

  _asn=$($_curl_base -ks -m "$_timeout" "https://ip-api.com/line/${_ip}?fields=as")
  _state=$(echo $?)

  if [[ -z "$_ip" ]] || [[ "$_ip" == "null" ]] || [[ "$_state" -ne 0 ]]; then
    echo -en "Unsuccessful ASN gathering.\\n"
  else
    echo -en "$_ip > $_asn\\n"
  fi
}

#######################################
# Check if port is open on a host
# Dependencies: nc (netcat) or bash /dev/tcp
# Arguments:
#   $1 - hostname or IP
#   $2 - port number
# Returns:
#   Status message
#######################################
function CheckPort() {
  local _host="$1"
  local _port="$2"

  if [[ -z "$_host" ]] || [[ -z "$_port" ]]; then
    echo "Usage: CheckPort <host> <port>"
    return 1
  fi

  if command -v nc &> /dev/null; then
    if nc -z -w 2 "$_host" "$_port" 2>/dev/null; then
      echo "Port $_port on $_host is OPEN"
      return 0
    else
      echo "Port $_port on $_host is CLOSED"
      return 1
    fi
  else
    # Fallback to bash's /dev/tcp
    if timeout 2 bash -c "cat < /dev/null > /dev/tcp/$_host/$_port" 2>/dev/null; then
      echo "Port $_port on $_host is OPEN"
      return 0
    else
      echo "Port $_port on $_host is CLOSED"
      return 1
    fi
  fi
}

#######################################
# Get public IP address
# Dependencies: curl
# Returns:
#   Public IP address
#######################################
function GetPublicIP() {
  local _timeout="10"
  local _ip

  _ip=$(curl -s -m "$_timeout" https://api.ipify.org 2>/dev/null)
  
  if [[ -z "$_ip" ]]; then
    _ip=$(curl -s -m "$_timeout" https://ifconfig.me 2>/dev/null)
  fi

  if [[ -z "$_ip" ]]; then
    echo "Failed to retrieve public IP"
    return 1
  else
    echo "Public IP: $_ip"
  fi
}

#######################################
# Get local IP addresses
# Returns:
#   List of local IP addresses
#######################################
function GetLocalIP() {
  if command -v ip &> /dev/null; then
    ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1'
  elif command -v ifconfig &> /dev/null; then
    ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'
  else
    echo "Neither 'ip' nor 'ifconfig' command found"
    return 1
  fi
}

#######################################
# Ping sweep a subnet
# Dependencies: ping
# Arguments:
#   Subnet in format 192.168.1 (without last octet)
# Returns:
#   List of responding hosts
#######################################
function PingSweep() {
  local _subnet="$1"

  if [[ -z "$_subnet" ]]; then
    echo "Usage: PingSweep <subnet> (e.g., 192.168.1)"
    return 1
  fi

  echo "Scanning subnet ${_subnet}.0/24..."
  for i in {1..254}; do
    (ping -c 1 -W 1 "${_subnet}.${i}" &>/dev/null && echo "${_subnet}.${i} is up") &
  done
  wait
}

#######################################
# Check HTTP/HTTPS response code
# Dependencies: curl
# Arguments:
#   URL to check
# Returns:
#   HTTP status code and message
#######################################
function CheckHTTP() {
  local _url="$1"

  if [[ -z "$_url" ]]; then
    echo "Usage: CheckHTTP <url>"
    return 1
  fi

  local _code=$(curl -o /dev/null -s -w "%{http_code}" "$_url")
  echo "HTTP Status Code for $_url: $_code"
  
  case $_code in
    200) echo "✓ OK" ;;
    301|302) echo "↪ Redirect" ;;
    403) echo "✗ Forbidden" ;;
    404) echo "✗ Not Found" ;;
    500) echo "✗ Internal Server Error" ;;
    503) echo "✗ Service Unavailable" ;;
    *) echo "Status: $_code" ;;
  esac
}

#######################################
# List open ports on local machine
# Dependencies: ss or netstat
# Returns:
#   List of listening ports
#######################################
function ListOpenPorts() {
  if command -v ss &> /dev/null; then
    echo "Listening TCP ports:"
    ss -tlnp 2>/dev/null | grep LISTEN
  elif command -v netstat &> /dev/null; then
    echo "Listening TCP ports:"
    netstat -tlnp 2>/dev/null | grep LISTEN
  else
    echo "Neither 'ss' nor 'netstat' command found"
    return 1
  fi
}

#######################################
# DNS lookup with multiple record types
# Dependencies: dig or nslookup
# Arguments:
#   Domain name
# Returns:
#   DNS records (A, MX, NS, TXT)
#######################################
function DNSLookup() {
  local _domain="$1"

  if [[ -z "$_domain" ]]; then
    echo "Usage: DNSLookup <domain>"
    return 1
  fi

  if command -v dig &> /dev/null; then
    echo "=== A Records ==="
    dig +short "$_domain" A
    echo -e "\\n=== MX Records ==="
    dig +short "$_domain" MX
    echo -e "\\n=== NS Records ==="
    dig +short "$_domain" NS
    echo -e "\\n=== TXT Records ==="
    dig +short "$_domain" TXT
  elif command -v nslookup &> /dev/null; then
    echo "=== DNS Lookup for $_domain ==="
    nslookup "$_domain"
  else
    echo "Neither 'dig' nor 'nslookup' command found"
    return 1
  fi
}
