#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.11/32
net add interface swp1 ip address 10.0.0.1/24
net add interface swp2 ip address 10.0.1.1/30
net add interface swp3 ip address 10.0.1.13/30
net add interface swp4 ip address 10.0.1.21/30

# OSPF config
net add ospf passive-interface default
net add ospf router-id 172.16.12.11

net add ospf network 172.16.12.11/32 area 0
net add ospf network 10.0.0.1/24 area 0
net add ospf network 10.0.1.1/30 area 0
net add ospf network 10.0.1.13/30 area 0
net add ospf network 10.0.1.21/30 area 0

net del ospf passive-interface swp1
net del ospf passive-interface swp2
net del ospf passive-interface swp3
net del ospf passive-interface swp4

net add interface swp1 ospf bfd 4 400 400
net add interface swp2 ospf bfd 4 400 400
net add interface swp3 ospf bfd 4 400 400
net add interface swp4 ospf bfd 4 400 400


net pending
net commit

reboot
