#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.12/32
net add interface swp1 ip address 10.0.0.2/24
net add interface swp2 ip address 10.0.1.5/30
net add interface swp3 ip address 10.0.1.17/30
net add interface swp4 ip address 10.0.1.25/30

net pending
net commit
# ISIS config
sed -i 's/isisd=no/isisd=yes/g' /etc/frr/daemons

cat <<EOF > /etc/frr/frr.conf
log syslog informational
!
router isis spine2
  net 49.0001.0000.0000.0002.00
  hostname dynamic
!
interface swp1
  ip router isis spine2
  isis circuit-type level-2-only
!
interface swp2
  ip router isis spine2
  isis circuit-type level-1-only
!
interface swp3
  ip router isis spine2
  isis circuit-type level-1-only
!
interface swp4
  ip router isis spine2
  isis circuit-type level-1-only
!

EOF

reboot
