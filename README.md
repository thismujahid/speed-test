# tnet ⚡

`tnet` is a lightweight, blazing-fast Bash CLI tool designed for Debian/Ubuntu-based Linux distributions. It allows you to check your internet connection speed directly from your terminal and get only the clean, essential metrics (**Ping, Download, and Upload**) without any clutter or extra verbose output.

> [!IMPORTANT]
> **Compatibility Note:** This script is specifically designed for systems using the **APT package manager** (such as Ubuntu, Debian, Pop!\_OS, Linux Mint, etc.). It will not work on Arch, Fedora, or macOS out of the box.

---

## ✨ Features

- **One-Command Setup:** Install the tool instantly via a simple, secure Curl-to-Bash script.
- **Smart Dependency Management:** The installer automatically checks for `jq` and the official `Speedtest CLI` by Ookla. If missing, it fetches and installs them cleanly using APT.
- **Pre-Installation Check:** If `tnet` is already installed, the script safely exits instantly to prevent redundant `apt update` calls and overwrite issues.
- **Clean & Modern UI:** Displays a smooth, minimal `Testing... ⚡` indicator while running. Once finished, it clears the indicator and prints the neat, colorized final output.
- **System-wide Native Command:** Installs as a standalone binary in your system path. You can run `tnet` from any directory instantly—no aliases or manual `.bashrc` sourcing required.

---

## 🚀 Installation

Open your terminal and run the following command to download and install `tnet` automatically:

```bash
curl -sSL https://raw.githubusercontent.com/thismujahid/speed-test/main/install.sh | bash

```

### What happens behind the scenes?

1. **Validation:** Checks if `tnet` already exists on the system.
2. **Dependency Check:** Updates APT lists and securely fetches `jq` (for JSON processing) and the official **Ookla Speedtest repository** (ensuring maximum speed test accuracy).
3. **Configuration:** Compiles the optimized runner script, moves it into the global binary directory (`/usr/local/bin/tnet`), and grants it execution permissions (`chmod +x`).

---

## 📖 Usage

Once installed successfully, simply type the following command anywhere in your terminal:

```bash
tnet

```

### Demo Sequence

**During the test:**

```text
Testing... ⚡

```

**Upon completion** (the indicator is completely wiped and replaced clean):

```text
Ping: 9 ms
Download: 15 Mbps
Upload: 1 Mbps

```

### Uninstallation

If you ever want to remove `tnet` from your system, simply run the tool with the `-r` or `--remove` flag:

```bash
tnet -r

```

_Note: If your local user configuration requires it, you might need to prepend `sudo` to the command (`sudo tnet -r`)._

---

## 🛠️ Core Dependencies

The tool automates the installation of these mandatory packages:

- **Ookla Speedtest CLI:** The official, native engine by Ookla for precise ping and high-bandwidth calculations.
- **jq:** A flexible, command-line JSON processor used to slice and parse the exact data blocks needed.
