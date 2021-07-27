#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.24/32
net add interface swp2 ip address 10.3.0.1/24

net add bgp autonomous-system 65201
net add bgp router-id 172.16.12.24

net add bgp neighbor swp1 remote-as external
net add bgp neighbor swp1 bfd

net add bgp ipv4 unicast network 10.3.0.1/24

net pending
net commit

reboot
