#!/bin/bash

net add interface swp1 ip address 10.3.0.100/24
net add routing route 0.0.0.0/0 10.3.0.1
net pending
net commit
reboot