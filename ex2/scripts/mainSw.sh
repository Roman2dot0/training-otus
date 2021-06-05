#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.1/32

# Create vlan-aware bridge. Must be "bridge"
net add bridge bridge ports swp1-3
net add bridge bridge vids 2-3724 # 3724-3999 - reserved
net add bridge bridge pvid 1

net add vlan 1 ip address 10.0.0.100/24

# OSPF config
net add ospf passive-interface default
net add ospf router-id 172.16.12.1

net add ospf network 172.16.12.1/32 area 0
net add ospf network 10.0.0.1/24 area 0
net add ospf network 10.0.0.100/24 area 0

net del ospf passive-interface bridge

net add interface bridge ospf bfd 4 400 400


net pending
net commit

reboot
