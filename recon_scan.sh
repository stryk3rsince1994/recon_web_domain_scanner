#!/bin/bash

# Comprehensive Security Recon Script
# Usage: ./recon_scan.sh https://example.com

# Configuration
TARGET="$1"
OUTPUT_DIR="$HOME/Desktop/scan_results"
REPORT_DIR="$OUTPUT_DIR/$(date +%Y%m%d_%H%M%S)"
HEADER="X-Bug-Bounty: true"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Check dependencies
check_deps() {
    command -v curl >/dev/null 2>&1 || { echo -e "${RED}Error: curl is required${NC}"; exit 1; }
    command -v nmap >/dev/null 2>&1 || { echo -e "${RED}Error: nmap is required${NC}"; exit 1; }
    command -v dig >/dev/null 2>&1 || { echo -e "${RED}Error: dig is required${NC}"; exit 1; }
}

# Create output directory
setup() {
    mkdir -p "$REPORT_DIR" || { echo -e "${RED}Failed to create output directory${NC}"; exit 1; }
}

# HTML analysis functions
scan_injection_points() {
    echo -e "${YELLOW}\n[+] Scanning for injection points...${NC}"
    curl -s -H "$HEADER" "$TARGET" | tee "$REPORT_DIR/page_source.html" | grep -PHin \
    "(<form[^>]*>|type=['\"]?password['\"]?|\bon[a-z]+=|\b(action|src)=['\"]?http://)" \
    > "$REPORT_DIR/injection_points.txt"
}

scan_sensitive_info() {
    echo -e "${YELLOW}\n[+] Scanning for sensitive information...${NC}"
    curl -s -H "$HEADER" "$TARGET" | grep -PHi \
    "([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}|AKIA[0-9A-Z]{16}|[0-9a-fA-F]{32}|password|passwd|pwd)" \
    > "$REPORT_DIR/sensitive_info.txt"
}

# Network reconnaissance
scan_network() {
    echo -e "${YELLOW}\n[+] Performing DNS lookup...${NC}"
    DOMAIN=$(echo "$TARGET" | awk -F/ '{print $3}')
    dig +short "$DOMAIN" > "$REPORT_DIR/ip_addresses.txt"
    
    echo -e "${YELLOW}\n[+] Scanning open ports...${NC}"
    nmap -T4 -p- --open "$DOMAIN" > "$REPORT_DIR/nmap_scan.txt"
}

# Main function
main() {
    check_deps
    setup
    echo -e "${GREEN}\n=== Starting Security Recon Scan ===${NC}"
...

    echo -e "${GREEN}\n=== Starting Security Recon Scan ===${NC}"
    echo -e "Target: $TARGET"
    echo -e "Output Directory: $REPORT_DIR"
    
    scan_injection_points
    scan_sensitive_info
    scan_network
    
    echo -e "${GREEN}\n=== Scan Complete ===${NC}"
    echo -e "Results saved to: $REPORT_DIR"
    echo -e "Remember to verify findings manually!"
}

# Argument check
if [ -z "$1" ]; then
    echo -e "${RED}Error: Please provide target URL as argument${NC}"
    exit 1
fi

main
