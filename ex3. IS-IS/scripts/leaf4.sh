#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.24/32
net add interface swp1 ip address 10.0.1.10/30
net add interface swp2 ip address 10.3.0.1/24

net pending
net commit
# ISIS config
sed -i 's/isisd=no/isisd=yes/g' /etc/frr/daemons

cat <<EOF > /etc/frr/frr.conf
log syslog informational
!
router isis leaf4
  net 49.0002.0000.0000.0014.00
  hostname dynamic
!
interface swp1
  ip router isis leaf4
  isis circuit-type level-1-only
!
interface swp2
  ip router isis leaf4
  isis passive
!
EOF

reboot
