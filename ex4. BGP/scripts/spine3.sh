#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.13/32
net add interface swp1 ip address 10.0.0.3/24

net add bgp autonomous-system 65200
net add bgp router-id 172.16.12.13

net add bgp neighbor 10.0.0.100 remote-as external
net add bgp neighbor swp2 remote-as external

net add bgp neighbor 10.0.0.100 bfd
net add bgp neighbor swp2 bfd

net pending
net commit

reboot
