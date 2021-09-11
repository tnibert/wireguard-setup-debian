#! /bin/bash

# install wireguard
apt install wireguard
modprobe wireguard
lsmod | grep wireguard

# generate keys
wg genkey > private.key
cat private.key | wg pubkey > public.key

# replace this with the actual public key and ip of the server
serverpubkey=SeRvErPUBLICkEySeRvErPUBLICkEySeRvErPUBLICk
serverip=1.2.3.4

# NB: AllowedIPs specifies what IP addresses to forward, and this config forwards everything
# ideally we don't want to forward IPs in our LAN subnet
# the route (in Linux) for your LAN *should* be more specific than wireguard's route, making it take
# precedence, however if your connection to your LAN goes away, this is something to be aware of
cat >> /etc/wireguard/wg0c.conf << EOF
[Interface]
Address = 172.16.16.2/24
SaveConfig = false
ListenPort = 47824
FwMark = 0x1234
PrivateKey = `cat private.key`

[Peer]
PublicKey = $serverpubkey
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $serverip:5544
PersistentKeepalive = 10
EOF

wg-quick up wg0c
wg show
