#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.13/32
net add interface swp1 ip address 10.0.0.3/24
net add interface swp2 ip address 10.0.1.9/30

net pending
net commit
# ISIS config
sed -i 's/isisd=no/isisd=yes/g' /etc/frr/daemons

cat <<EOF > /etc/frr/frr.conf
log syslog informational
!
router isis spine3
  net 49.0002.0000.0000.0003.00
  hostname dynamic
!
interface swp1
  ip router isis spine3
  isis circuit-type level-2-only
!
interface swp2
  ip router isis spine3
  isis circuit-type level-1-only
!

EOF

reboot
