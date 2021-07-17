#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.24/32
net add interface swp1 ip address 10.0.1.10/30
net add interface swp2 ip address 10.3.0.1/24

# OSPF config
net add ospf passive-interface default
net add ospf router-id 172.16.12.24

net add ospf area 4 stub
net add ospf network 10.0.1.10/30 area 4
net add ospf network 10.3.0.1/24 area 4

net del ospf passive-interface swp1
net del ospf passive-interface swp2

net add interface swp1 ospf bfd 4 400 400


net pending
net commit

reboot
