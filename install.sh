#!/bin/bash

# تحديد مسار التثبيت
INSTALL_DIR="/usr/local/bin"
TARGET_FILE="$INSTALL_DIR/tnet"

# التأكد لو الأداة متثبتة قبل كده ويخرج فوراً
if [ "$1" != "-r" ] && [ "$1" != "--remove" ] && command -v tnet &> /dev/null; then
    echo -e "\e[32m[✓] tnet is already installed on your system!\e[0m"
    exit 0
fi

echo -e "\e[34m[*] Starting tnet installation...\e[0m"

# 1. التأكد من وجود jq وتثبيته
if ! command -v jq &> /dev/null; then
    echo -e "\e[33m[+] Installing dependency: jq...\e[0m"
    sudo apt-get update -y && sudo apt-get install jq -y &> /dev/null
fi

# 2. التأكد من وجود speedtest وتثبيته بالطريقة الرسمية الذكية
if ! command -v speedtest &> /dev/null; then
    echo -e "\e[33m[+] Installing dependency: Speedtest CLI...\e[0m"
    sudo apt-get install curl gnupg apt-transport-https lsb-release -y &> /dev/null
    
    # [حل المشكلة] تحديد اسم النسخة بدقة (Fallback to Ubuntu Codename if custom distro)
    CODENAME=$(lsb_release -cs)
    if [ "$CODENAME" == "resolute" ] || ! curl -sI "https://packagecloud.io/ookla/speedtest-cli/ubuntu/dists/$CODENAME/Release" | grep -q "200 OK"; then
        # لو الاسم مش موجود على سيرفر Ookla، هنقيب الـ UBUNTU_CODENAME الأصلي من السيستم
        if [ -f /etc/os-release ]; then
            CODENAME=$(grep -oP 'UBUNTU_CODENAME=\K\w+' /etc/os-release 2>/dev/null)
            # لو لسه فاضي (زي في دبيان الصافي مثلاً) نخليه jammy أو noble كإجراء احتياطي مستقر
            [ -z "$CODENAME" ] && CODENAME=$(grep -oP 'VERSION_CODENAME=\K\w+' /etc/os-release 2>/dev/null)
        fi
        [ -z "$CODENAME" ] && CODENAME="jammy"
    fi

    # تنظيف أي ملفات قديمة مسببة تكرار أو أخطاء 404
    sudo rm -f /etc/apt/sources.list.d/speedtest.list /etc/apt/sources.list.d/ookla_speedtest-cli.list

    # إضافة المفتاح والمستودع بالاسم الصحيح المدعوم
    curl -fsSL https://packagecloud.io/ookla/speedtest-cli/gpgkey | sudo gpg --dearmor --yes -o /etc/apt/keyrings/ookla_speedtest-cli-archive-keyring.gpg &> /dev/null
    echo "deb [signed-by=/etc/apt/keyrings/ookla_speedtest-cli-archive-keyring.gpg] https://packagecloud.io/ookla/speedtest-cli/ubuntu/ $CODENAME main" | sudo tee /etc/apt/sources.list.d/ookla_speedtest-cli.list &> /dev/null
    
    sudo apt-get update -y && sudo apt-get install speedtest -y &> /dev/null
fi

# 3. كتابة سكريبت التشغيل جوه الـ /usr/local/bin/tnet مع دعم خيار الحذف
echo -e "\e[33m[+] Configuring tnet executable...\e[0m"

sudo tee $TARGET_FILE > /dev/null << 'EOF'
#!/bin/bash

if [ "$1" == "-r" ] || [ "$1" == "--remove" ]; then
    echo -e "\e[33m[*] Removing tnet from your system...\e[0m"
    sudo rm -f "$0"
    sudo rm -f /etc/apt/sources.list.d/ookla_speedtest-cli.list
    if [ $? -eq 0 ]; then
        echo -e "\e[32m[✓] tnet has been completely removed.\e[0m"
        exit 0
    else
        echo -e "\e[31mError: Failed to remove tnet. Please try running with sudo: sudo tnet -r\e[0m"
        exit 1
    fi
fi

echo -e "\e[33mTesting... ⚡\e[0m"

result=$(speedtest --format=json 2>/dev/null)
echo -e "\e[1A\e[K"

if [ -z "$result" ] || echo "$result" | grep -q "Error"; then
    echo -e "\e[31mError: Network issue or Speedtest failed.\e[0m"
    exit 1
fi

echo "$result" | jq -r '
  "\u001b[32mPing:\u001b[0m \(.ping.latency | round) ms",
  "\u001b[32mDownload:\u001b[0m \((.download.bandwidth / 125000) | round) Mbps",
  "\u001b[32mUpload:\u001b[0m \((.upload.bandwidth / 125000) | round) Mbps"
'
EOF

# 4. إعطاء صلاحيات التشغيل للأمر الجديد
sudo chmod +x $TARGET_FILE

echo -e "\e[32m[✓] tnet installed successfully! You can now use the 'tnet' command anywhere.\e[0m"