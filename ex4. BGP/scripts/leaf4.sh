#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.24/32
net add interface swp1 ip address 10.0.1.10/30
net add interface swp2 ip address 10.3.0.1/24

net pending
net commit

reboot
