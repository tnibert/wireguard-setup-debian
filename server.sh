#! /bin/bash

# originally based on https://docs.linuxconsulting.mn.it/notes/setup-wireguard-vpn-on-debian9, with some modifications

# install wireguard
apt install wireguard
lsmod | grep wireguard
modprobe wireguard

# generate keys
wg genkey > private.key
cat private.key | wg pubkey > public.key

# variables for setup
iface=eth0
# replace this with the actual public key of the peer
peerpubkey=UsEr1PUBLICkEyUsEr1PUBLICkEyUsEr1PUBLICkey=

cat >> /etc/wireguard/wg0s.conf << EOF
[Interface]
Address = 172.16.16.1/24
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $iface -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $iface -j MASQUERADE
ListenPort = 5544
PrivateKey = `cat private.key`

[Peer]
PublicKey = $peerpubkey
AllowedIPs = 172.16.16.2/32
EOF

# for permanent forwarding
echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf
# for right now forwarding without reboot
echo 1 > /proc/sys/net/ipv4/ip_forward

# bring the interface up
wg-quick up wg0s
wg show

# start at boot
systemctl enable wg-quick@wg0s.service
