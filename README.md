## script & tools for a better terminal experience 🚀

#### System support

- macOS 10+
- Ubuntu 16+

#### How to install

`bash <(curl -sL https://raw.githubusercontent.com/librz/shell-scripts/main/init.sh)`

For users who cannot access github because of censorship, this project is also hosted under `https://realrz.com`, you can do:

`bash <(curl -sL https://realrz.com/shell-scripts/init.sh)`

#### Important notice

This script will change ssh listening port from the default `22` to `9000`, this is a delibrate choice to help avoid malicious attempts to scan/break into your VPS.

As of 2023, many VPS providers enable firewalla by default & only allow 22 in their default setting. You need to make sure port `9000` is open before running this script on your server, else there's no way to ssh into your server & you have to do full reinstall.

On Ubuntu, the firewall manager is `ufw`, you can check its status using `ufw status`. I personally would turn the firewall off by running `ufw disable`.

You can use namp to check whether a specific port is open on remote machine: `nmap -Pn {ip} -n {port}`

#### Disclaimer

This repo is open source thus 100% open for verification and risk checking. 

That being said, running init.sh required **sudo** access, do it at your own risk
