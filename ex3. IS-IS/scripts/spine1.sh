#!/bin/bash
# Set ip addresses
net add loopback lo ip address 172.16.12.11/32
net add interface swp1 ip address 10.0.0.1/24
net add interface swp2 ip address 10.0.1.1/30
net add interface swp3 ip address 10.0.1.13/30
net add interface swp4 ip address 10.0.1.21/30

# ISIS config
