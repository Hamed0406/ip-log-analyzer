# ip-log-analyzer
etwork Connection Logger &amp; IP Info Summarizer
### 🔍 Project: Network Connection Logger & IP Info Summarizer

This project logs all current network connections on an Ubuntu system using `conntrack`,
resolves IPs to hostnames (including reverse DNS and IPinfo lookup), and summarizes
external connections (org/country/city). Ideal for auditing, diagnostics, and connection awareness.

#### Features:
- 🧠 Smart hostname resolution with caching
- 🌍 External IP details via [ipinfo.io](https://ipinfo.io)
- 📄 Logging and CSV summary
- ⚙️ Cron job support for automation

#### Goal:
Clone and run a single install script to deploy the full system:
```bash
git clone https://github.com/YOUR_USERNAME/conntrack-monitor.git
cd conntrack-monitor
./setup.sh
