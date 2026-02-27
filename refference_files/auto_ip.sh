#!/bin/bash
echo "monitoring network interfaces..."
while true; do
    if ip link show enp0s20f0u1 >/dev/null 2>&1; then
        if ! ip addr show enp0s20f0u1  | grep -q "172.16.42.2"; then
            echo "interface enp0s20f0u1 appeared. Assigning 172.16.42.2..."
            sudo ip link set enp0s20f0u1 up
            sudo ip addr add 172.16.42.2/24 dev enp0s20f0u1
        fi
    fi
    sleep 0.5
done
