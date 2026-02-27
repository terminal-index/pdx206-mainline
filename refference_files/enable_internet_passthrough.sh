#!/bin/bash
# Running on host PC
sudo sysctl net.ipv4.ip_forward=1

HOST_IFACE=$(ip route show default | awk '/default/ {print $5}')
PHONE_IFACE="enp0s20f0u1"  # pdx206 rndis interface

sudo iptables -t nat -A POSTROUTING -o $HOST_IFACE -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i $PHONE_IFACE -o $HOST_IFACE -j ACCEPT
