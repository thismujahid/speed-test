#!/bin/bash

INSTALL_DIR="/usr/local/bin"
TARGET_FILE="$INSTALL_DIR/tnet"

if [ "$1" != "-r" ] && [ "$1" != "--remove" ] && command -v tnet &> /dev/null; then
    echo -e "\e[32m[✓] tnet is already installed on your system!\e[0m"
    exit 0
fi

if ! command -v snap &> /dev/null; then
    echo -e "\e[31m[!] Error: 'snapd' is not installed on your system.\e[0m"
    echo -e "\e[33m\nWhat is Snap? ✨\e[0m"
    echo "Snap is a powerful, modern package management system developed by Canonical."
    echo "Unlike traditional APT packages, Snaps are self-contained containerized applications."
    echo "This means they bundle all their required dependencies internally, ensuring they work"
    echo "flawlessly across any Linux distribution instantly—without broken packages or dependency hell."
    echo -e "\e[32m\nTo install snapd, run:\e[0m"
    echo "  sudo apt update && sudo apt install snapd -y"
    echo -e "\e[32mThen run this installer script again.\e[0m"
    exit 1
fi

echo -e "\e[34m[*] Starting tnet installation via Snap...\e[0m"

if ! command -v jq &> /dev/null; then
    echo -e "\e[33m[+] Installing dependency: jq...\e[0m"
    sudo apt-get update -y && sudo apt-get install jq -y
    
    if ! command -v jq &> /dev/null; then
        echo -e "\e[31m[!] Error: Failed to install 'jq'. Installation aborted.\e[0m"
        exit 1
    fi
fi

if ! command -v speedtest &> /dev/null && [ ! -f /snap/bin/speedtest ]; then
    echo -e "\e[33m[+] Installing dependency: Speedtest CLI via Snap...\e[0m"
    sudo snap install speedtest
    
    if ! command -v speedtest &> /dev/null && [ ! -f /snap/bin/speedtest ]; then
        echo -e "\e[31m[!] Error: Failed to install 'speedtest' via snap. Installation aborted.\e[0m"
        exit 1
    fi
fi

echo -e "\e[33m[+] Configuring tnet executable...\e[0m"

sudo tee $TARGET_FILE > /dev/null << 'EOF'
#!/bin/bash

if [ "$1" == "-r" ] || [ "$1" == "--remove" ]; then
    echo -e "\e[33m[*] Removing tnet and all its dependencies from your system...\e[0m"
    
    if command -v speedtest &> /dev/null || [ -f /snap/bin/speedtest ]; then
        echo -e "\e[33m[+] Uninstalling Speedtest CLI (Snap)...\e[0m"
        sudo snap remove speedtest &> /dev/null
    fi

    if command -v jq &> /dev/null; then
        echo -e "\e[33m[+] Uninstalling jq (APT)...\e[0m"
        sudo apt-get remove --purge jq -y &> /dev/null
        sudo apt-get autoremove -y &> /dev/null
    fi

    sudo rm -f "$0"
    
    if [ $? -eq 0 ]; then
        echo -e "\e[32m[✓] tnet, Speedtest CLI, and jq have been completely removed.\e[0m"
        exit 0
    else
        echo -e "\e[31mError: Failed to completely remove tnet.\e[0m"
        exit 1
    fi
fi

echo -e "\e[33mTesting... ⚡\e[0m"

SPEEDTEST_CMD="speedtest"
[ ! -x "$(command -v speedtest)" ] && [ -x /snap/bin/speedtest ] && SPEEDTEST_CMD="/snap/bin/speedtest"

result=$($SPEEDTEST_CMD --format=json --accept-license --accept-gdpr 2>/dev/null)
echo -e "\e[1A\e[K"

if [ -z "$result" ] || echo "$result" | grep -q "Error"; then
    echo -e "\e[31mError: Network issue or Speedtest failed.\e[0m"
    exit 1
fi

echo "$result" | jq -r '
  "\u001b[32mPing:\u001b[0m \(.ping.latency | round) ms",
  "\u001b[32mDownload:\u001b[0m \((.download.bandwidth / 125000) | round) Mbps",
  "\u001b[32mUpload:\u001b[0m \((.download.bandwidth / 125000) | round) Mbps"
'
EOF

sudo chmod +x $TARGET_FILE

echo -e "\e[32m[✓] tnet installed successfully! You can now use the 'tnet' command anywhere.\e[0m"