#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.23/32
net add interface swp1 ip address 10.0.1.22/30
net add interface swp2 ip address 10.0.1.26/30
net add interface swp3 ip address 10.2.0.1/24

# OSPF config
net add ospf passive-interface default
net add ospf router-id 172.16.12.23

net add ospf area 3 stub
net add ospf network 10.0.1.22/30 area 3
net add ospf network 10.0.1.26/30 area 3
net add ospf network 10.2.0.1/24 area 3

net del ospf passive-interface swp1
net del ospf passive-interface swp2

net add interface swp1 ospf bfd 4 400 400
net add interface swp2 ospf bfd 4 400 400


net pending
net commit

reboot
