#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.21/32
net add interface swp2 ip address 10.0.1.2/30
net add interface swp3 ip address 10.0.1.6/30

# MLAG and bondig
net add loopback lo ip address 10.10.0.1/30
net add bond bond1 bond slaves swp4
net add bond bond1 alias clientbond on swp4

net add bond bond1 clag id 1

net add bridge bridge ports bond1
net add bridge bridge vids 2-3724 # 3724-3999 - reserved
net add bridge bridge pvid 1
net add vlan 1 ip address 10.1.0.1/24
net add clag peer sys-mac 44:38:39:BE:EF:AA interface swp1 primary backup-ip 10.10.0.2
net add interface peerlink.4094 clag args --initDelay 100

# OSPF config
net add ospf passive-interface default
net add ospf router-id 172.16.12.21

net add ospf area 1 stub
net add ospf network 10.1.0.1/24 area 1
net add ospf network 10.0.1.2/30 area 1
net add ospf network 10.0.1.6/30 area 1

net del ospf passive-interface swp2
net del ospf passive-interface swp3

net add interface swp2 ospf bfd 4 400 400
net add interface swp3 ospf bfd 4 400 400

net pending
net commit

reboot