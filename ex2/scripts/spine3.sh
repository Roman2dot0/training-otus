#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.13/32
net add interface swp1 ip address 10.0.0.3/24
net add interface swp2 ip address 10.0.1.9/30

# OSPF config
net add ospf passive-interface default
net add ospf router-id 172.16.12.13

net add ospf network 172.16.12.13/32 area 0
net add ospf network 10.0.0.3/24 area 0
net add ospf network 10.0.1.9/30 area 0

net del ospf passive-interface swp1
net del ospf passive-interface swp2

net add interface swp1 ospf bfd 4 400 400
net add interface swp2 ospf bfd 4 400 400


net pending
net commit

reboot
