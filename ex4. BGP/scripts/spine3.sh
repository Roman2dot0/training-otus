#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.13/32
net add interface swp1 ip address 10.0.0.3/24
net add interface swp2 ip address 10.0.1.9/30

net pending
net commit

reboot
