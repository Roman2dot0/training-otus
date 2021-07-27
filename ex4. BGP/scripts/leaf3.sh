#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.23/32
net add interface swp3 ip address 10.2.0.1/24

# BGP
net add bgp autonomous-system 65103
net add bgp router-id 172.16.12.23
net add bgp neighbor swp1 remote-as external
net add bgp neighbor swp2 remote-as external

net add bgp neighbor swp1 bfd
net add bgp neighbor swp2 bfd

net add bgp ipv4 unicast network 10.2.0.1/24

net pending
net commit

reboot

