#!/bin/bash

INSTALL_DIR="/usr/local/bin"
TARGET_FILE="$INSTALL_DIR/tnet"

if [ "$1" != "-r" ] && [ "$1" != "--remove" ] && command -v tnet &> /dev/null; then
    echo -e "\e[32m[✓] tnet is already installed on your system!\e[0m"
    exit 0
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
    echo -e "\e[33m[*] Removing tnet from your system...\e[0m"
    sudo rm -f "$0"
    if [ $? -eq 0 ]; then
        echo -e "\e[32m[✓] tnet has been completely removed.\e[0m"
        exit 0
    else
        echo -e "\e[31mError: Failed to remove tnet.\e[0m"
        exit 1
    fi
fi

echo -e "\e[33mTesting... ⚡\e[0m"

SPEEDTEST_CMD="speedtest"
[ ! -x "$(command -v speedtest)" ] && [ -x /snap/bin/speedtest ] && SPEEDTEST_CMD="/snap/bin/speedtest"

result=$($SPEEDTEST_CMD --format=json 2>/dev/null)
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