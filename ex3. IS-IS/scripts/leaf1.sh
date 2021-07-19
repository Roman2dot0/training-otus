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

net pending
net commit

# ISIS config
sed -i 's/isisd=no/isisd=yes/g' /etc/frr/daemons

cat <<EOF > /etc/frr/frr.conf
log syslog informational
!
router isis leaf1
  net 49.0001.0000.0000.0011.00
  hostname dynamic
!
interface swp2
  ip router isis leaf1
  isis circuit-type level-1-only
!
interface swp3
  ip router isis leaf1
  isis circuit-type level-1-only
!
interface vlan1
  ip router isis leaf1
  isis passive
!
EOF

reboot
