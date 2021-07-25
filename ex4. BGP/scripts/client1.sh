#!/bin/bash

net add bond bond0 bond slaves swp1-2
net add bond bond0 ip address 10.1.0.100/24
net add routing route 0.0.0.0/0 10.1.0.1
net add routing route 0.0.0.0/0 10.1.0.2
net pending
net commit
reboot
