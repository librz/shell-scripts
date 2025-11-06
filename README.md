## script & tools for a better terminal experience 🚀

#### System support

- macOS 15+
- Ubuntu 20+

#### How to install

`sudo bash <(curl -sL https://raw.githubusercontent.com/librz/shell-scripts/main/init.sh)`

#### Important notice

This script will change ssh listening port from the default `22` to `9000`, this is a delibrate choice to help avoid malicious attempts to scan/break into your VPS.

As of 2023, many VPS providers enable firewalla by default & only allow 22 in their default setting. You need to make sure port `9000` is open before running this script on your server, else there's no way to ssh into your server & you have to do full reinstall.

On Ubuntu, the firewall manager is `ufw`, you can check its status using `ufw status`. I personally would turn the firewall off by running `ufw disable`.

You can use namp to check whether a specific port is open on remote machine: `nmap -Pn {ip} -n {port}`

#### Disclaimer

This repo is open source thus 100% open for verification and risk checking. 

That being said, running `init.sh` requires **sudo** access, do it at your own risk.
