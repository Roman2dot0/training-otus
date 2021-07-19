#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.23/32
net add interface swp1 ip address 10.0.1.22/30
net add interface swp2 ip address 10.0.1.26/30
net add interface swp3 ip address 10.2.0.1/24

# ISIS config
