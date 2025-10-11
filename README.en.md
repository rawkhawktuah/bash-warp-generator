# Generate Cloudflare WARP config for AmneziaWG

This bash script will generate a Cloudflare WARP configuration for AmneziaWG.

It is not recommended to run it locally because RKN has blocked the requests required to obtain the config. Instead, run it on remote servers.

## Option 1: Aeza Terminator
1. Go to https://terminator.aeza.net
2. Choose `debian`
3. Paste the command:
```bash
bash <(wget --inet4-only -qO- https://raw.githubusercontent.com/ImMALWARE/bash-warp-generator/main/warp_generator.sh)
```
4. Once the config is generated, copy it or download it via the provided link and import it into AmneziaWG! 👍

## Option 2: Replit
1. Click here: [![Run on Repl.it](https://repl.it/badge/github/replit/upm)](https://replit.com/new/github/ImMALWARE/bash-warp-generator)
2. Create an account
3. Click the Run button at the top
4. Once the config is generated, copy it or download it via the provided link and import it into AmneziaWG! 👍

## Something not working?
### After connecting in AmneziaWG, nothing works; the "Transfer" field shows: Received 0 B
Unfortunately, AmneziaWG could not bypass your provider's WireGuard blocking :( \
https://github.com/ImMALWARE/bash-warp-generator/issues/5 \
You can also try disabling the kill-switch in the tunnel configuration.

### Another question?
Write in the chat: https://t.me/immalware_chat
