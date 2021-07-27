#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.1/32

# Create vlan-aware bridge. Must be "bridge"
net add bridge bridge ports swp1-3
net add bridge bridge vids 2-3724 # 3724-3999 - reserved
net add bridge bridge pvid 1

net add vlan 1 ip address 10.0.0.100/24

net add bgp autonomous-system 65000
net add bgp router-id 172.16.12.1

net add bgp neighbor 10.0.0.1 remote-as external
net add bgp neighbor 10.0.0.2 remote-as external
net add bgp neighbor 10.0.0.3 remote-as external

# net add bgp ipv4 unicast network 172.16.12.1/32

net add bgp neighbor 10.0.0.1 bfd
net add bgp neighbor 10.0.0.2 bfd
net add bgp neighbor 10.0.0.3 bfd

net pending
net commit

reboot
