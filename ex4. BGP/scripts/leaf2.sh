#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.22/32

# MLAG and bondig
net add loopback lo ip address 10.10.0.2/30
net add bond bond1 bond slaves swp4
net add bond bond1 alias clientbond on swp4
net add bond bond1 clag id 1
net add bridge bridge ports bond1
net add bridge bridge vids 2-3724 # 3724-3999 - reserved
net add bridge bridge pvid 1
net add vlan 1 ip address 10.1.0.2/24
net add clag peer sys-mac 44:38:39:BE:EF:AA interface swp1 primary backup-ip 10.10.0.1
net add interface peerlink.4094 clag args --initDelay 100


# BGP
net add bgp autonomous-system 65102
net add bgp router-id 172.16.12.22
net add bgp neighbor swp2 remote-as external
net add bgp neighbor swp3 remote-as external

net add bgp neighbor swp2 bfd
net add bgp neighbor swp3 bfd

net add bgp ipv4 unicast network 10.1.0.2/24

net pending
net commit

reboot
