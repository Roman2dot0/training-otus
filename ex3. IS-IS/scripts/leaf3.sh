#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.23/32
net add interface swp1 ip address 10.0.1.22/30
net add interface swp2 ip address 10.0.1.26/30
net add interface swp3 ip address 10.2.0.1/24

net pending
net commit
# ISIS config
sed -i 's/isisd=no/isisd=yes/g' /etc/frr/daemons


cat <<EOF > /etc/frr/frr.conf
log syslog informational
!
router isis leaf3
  net 49.0001.0000.0000.0013.00
  hostname dynamic
!
interface swp1
  ip router isis leaf3
  isis circuit-type level-1-only
!
interface swp2
  ip router isis leaf3
  isis circuit-type level-1-only
!
interface swp3
  ip router isis leaf3
  isis passive
!

EOF

reboot

