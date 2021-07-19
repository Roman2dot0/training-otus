#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.12/32
net add interface swp1 ip address 10.0.0.2/24
net add interface swp2 ip address 10.0.1.5/30
net add interface swp3 ip address 10.0.1.17/30
net add interface swp4 ip address 10.0.1.25/30

# OSPF config
net add ospf passive-interface default
net add ospf router-id 172.16.12.12

net add ospf network 10.0.0.2/24 area 0

net add ospf area 1 stub no-summary
net add ospf network 10.0.1.5/30 area 1

net add ospf area 2 stub no-summary
net add ospf network 10.0.1.17/30 area 2

net add ospf area 3 stub no-summary
net add ospf network 10.0.1.25/30 area 3

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