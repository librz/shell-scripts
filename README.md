## script & tools for a better terminal experience 🚀

#### system support

- macOS 10+
- Ubuntu 16+

#### how to install

`bash <(curl -sL https://raw.githubusercontent.com/librz/shell-scripts/main/init.sh)`

For users who cannot access github because of censorship, this project is also hosted under `https://realrz.com`, you can do:

`bash <(curl -sL https://realrz.com/shell-scripts/init.sh)`

#### important notice

This script will change ssh listening port from the default `22` to `9000`, this is a delibrate choice to help avoid malicious attempts to scan/break into your VPS.

As of 2023, many VPS providers enable firewalla by default & only allow 22 in their default setting. You need to make sure port `9000` is open before running this script on your server, else there's no way to ssh into your server & the only solution is to do full reinstall.

On Ubuntu, the firewall manager is `ufw`, you can check its status using `ufw status`. I personally would turn the firewall off by running `ufw disable`.

#### disclaimer

running init.sh required sudo access, do it at your own risk
