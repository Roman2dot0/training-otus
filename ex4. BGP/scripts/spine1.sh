#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.11/32
net add interface swp1 ip address 10.0.0.1/24

net add bgp autonomous-system 65100
net add bgp router-id 172.16.12.11

net add bgp neighbor 10.0.0.100 remote-as external
net add bgp neighbor swp2 remote-as external
net add bgp neighbor swp3 remote-as external
net add bgp neighbor swp4 remote-as external

# net add bgp ipv4 unicast network 172.16.12.11/32

net add bgp neighbor 10.0.0.100 bfd
net add bgp neighbor swp2 bfd
net add bgp neighbor swp3 bfd
net add bgp neighbor swp4 bfd

net pending
net commit

reboot
