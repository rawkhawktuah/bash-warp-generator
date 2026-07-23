#!/bin/bash

clear

if [ -d "/home/runner" ] || [ ! -z "$REPL_ID" ]; then
    echo "[INFO] Running in Replit"
else
    mkdir -p ~/.cloudshell
    touch ~/.cloudshell/no-apt-get-warning

    sudo apt-get update -y --fix-missing
    sudo apt-get install -y wireguard-tools jq wget qrencode
fi

priv="${1:-$(wg genkey | tr -d '\n')}"
pub="${2:-$(printf "%s" "$priv" | wg pubkey | tr -d '\n')}"

API="https://api.cloudflareclient.com/v0i1909051800"

ins() {
    curl -s \
        -H 'User-Agent: okhttp/3.12.1' \
        -H 'Content-Type: application/json' \
        -X "$1" \
        "${API}/$2" \
        "${@:3}"
}

sec() {
    ins "$1" "$2" \
        -H "Authorization: Bearer $3" \
        "${@:4}"
}

response=$(ins POST reg \
-d "{\"install_id\":\"\",\"tos\":\"$(date -u +%FT%TZ)\",\"key\":\"${pub}\",\"fcm_token\":\"\",\"type\":\"ios\",\"locale\":\"en_US\"}")

id=$(echo "$response" | jq -r '.result.id')
token=$(echo "$response" | jq -r '.result.token')

[ "$id" = "null" ] && {
    echo "$response"
    exit 1
}

response=$(sec PATCH "reg/${id}" "$token" \
-d '{"warp_enabled":true}')

peer_pub=$(echo "$response" | jq -r '.result.config.peers[0].public_key')
client_ipv4=$(echo "$response" | jq -r '.result.config.interface.addresses.v4')
client_ipv6=$(echo "$response" | jq -r '.result.config.interface.addresses.v6')

HOSTS=(
"162.159.192"
"162.159.195"
"188.114.96"
"188.114.97"
"188.114.98"
"188.114.99"
"8.6.112"
"8.34.70"
"8.34.146"
"8.35.211"
"8.39.125"
"8.39.204"
"8.39.214"
"8.47.69"
)

PORTS=(
500 854 859 864 878 880 890 891 894 903 908
928 934 939 942 943 945 946 955 968 987 988
1002 1010 1014 1018 1070 1074 1180 1387
1701 1843 2371 2408 2506 3138 3476 3581
3854 4177 4198 4233 4500 5279 5956 7103
7152 7156 7281 7559 8319 8742 8854 8886
)

ENDPOINT_HOST="${HOSTS[$RANDOM % ${#HOSTS[@]}]}.$((RANDOM % 256))"
ENDPOINT_PORT="${PORTS[$RANDOM % ${#PORTS[@]}]}"

conf=$(cat <<-EOM
[Interface]
PrivateKey = ${priv}
S1 = 0
S2 = 0
S3 = 0
S4 = 0
Jc = 4
Jmin = 40
Jmax = 70
H1 = 1
H2 = 2
H3 = 3
H4 = 4
MTU = 1280
I1 = <b 0x494e56495445207369703a626f624062696c6f78692e636f6d205349502f322e300d0a5669613a205349502f322e302f55445020706333332e61746c616e74612e636f6d3b6272616e63683d7a39684734624b3737366173646864730d0a4d61782d466f7277617264733a2037300d0a546f3a20426f62203c7369703a626f624062696c6f78692e636f6d3e0d0a46726f6d3a20416c696365203c7369703a616c6963654061746c616e74612e636f6d3e3b7461673d313932383330313737340d0a43616c6c2d49443a20613834623463373665363637313040706333332e61746c616e74612e636f6d0d0a435365713a2033313431353920494e564954450d0a436f6e746163743a203c7369703a616c69636540706333332e61746c616e74612e636f6d3e0d0a436f6e74656e742d547970653a206170706c69636174696f6e2f7364700d0a436f6e74656e742d4c656e6774683a20300d0a0d0a>
I2 = <b 0x5349502f322e302031303020547279696e670d0a5669613a205349502f322e302f55445020706333332e61746c616e74612e636f6d3b6272616e63683d7a39684734624b3737366173646864730d0a546f3a20426f62203c7369703a626f624062696c6f78692e636f6d3e0d0a46726f6d3a20416c696365203c7369703a616c6963654061746c616e74612e636f6d3e3b7461673d313932383330313737340d0a43616c6c2d49443a20613834623463373665363637313040706333332e61746c616e74612e636f6d0d0a435365713a2033313431353920494e564954450d0a436f6e74656e742d4c656e6774683a20300d0a0d0a>
Address = ${client_ipv4}, ${client_ipv6}
DNS = 1.1.1.1, 2606:4700:4700::1111, 1.0.0.1, 2606:4700:4700::1001

[Peer]
PublicKey = ${peer_pub}
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = ${ENDPOINT_HOST}:${ENDPOINT_PORT}
EOM
)

AWG_JSON=$(cat <<-EOM
{
  "interface": {
    "private_key": "${priv}",
    "address": [
      "${client_ipv4}",
      "${client_ipv6}"
    ],
    "dns": [
      "1.1.1.1",
      "2606:4700:4700::1111",
      "1.0.0.1",
      "2606:4700:4700::1001"
    ],
    "mtu": 1280
  },
  "peers": [
    {
      "public_key": "${peer_pub}",
      "allowed_ips": [
        "0.0.0.0/0",
        "::/0"
      ],
      "endpoint": "${ENDPOINT_HOST}:${ENDPOINT_PORT}"
    }
  ]
}
EOM
)

AMNEZIA_JSON=$(cat <<-EOM
{
  "name": "Cloudflare WARP",
  "type": "awg",
  "config": {
    "privateKey": "${priv}",
    "address": [
      "${client_ipv4}",
      "${client_ipv6}"
    ],
    "dns": [
      "1.1.1.1",
      "2606:4700:4700::1111",
      "1.0.0.1",
      "2606:4700:4700::1001"
    ],
    "peer": {
      "publicKey": "${peer_pub}",
      "allowedIPs": [
        "0.0.0.0/0",
        "::/0"
      ],
      "endpoint": "${ENDPOINT_HOST}:${ENDPOINT_PORT}"
    },
    "mtu": 1280
  }
}
EOM
)
