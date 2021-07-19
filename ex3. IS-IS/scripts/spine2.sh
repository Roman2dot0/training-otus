#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.12/32
net add interface swp1 ip address 10.0.0.2/24
net add interface swp2 ip address 10.0.1.5/30
net add interface swp3 ip address 10.0.1.17/30
net add interface swp4 ip address 10.0.1.25/30

# ISIS config
