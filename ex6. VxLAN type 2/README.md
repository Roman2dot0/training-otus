![Архитектура сети](https://github.com/Roman2dot0/training-otus/blob/master/ex6.%20VXLAN%20type%202/vxlan_type2.png)
В данной работе нужно настроить простую l2 связность между client01 и client02 посредством evpn. Настройка lacp/vpc не нужна и leaf02 не работает.
В качестве всех устройств используется cisco nexus 9000v (9.3.8). На клиентах отключается stp для vlan, иначе интерфейс vlan 10 будет в состоянии down. 
Настройки лежат в configs. Проверяем, что всё работает


```
leaf01# sh ip route 
IP Route Table for VRF "default"
'*' denotes best ucast next-hop
'**' denotes best mcast next-hop
'[x/y]' denotes [preference/metric]
'%<string>' in via output denotes VRF <string>

10.1.1.1/32, ubest/mbest: 1/0
    *via 10.1.1.1, Eth1/1, [110/41], 01:16:14, ospf-underlay, intra
10.1.2.1/32, ubest/mbest: 1/0
    *via 10.1.2.1, Eth1/2, [110/41], 01:16:26, ospf-underlay, intra
10.1.101.1/32, ubest/mbest: 2/0, attached
    *via 10.1.101.1, Lo1, [0/0], 02:08:56, local
    *via 10.1.101.1, Lo1, [0/0], 02:08:56, direct
10.1.103.1/32, ubest/mbest: 2/0
    *via 10.1.1.1, Eth1/1, [110/81], 01:15:59, ospf-underlay, intra
    *via 10.1.2.1, Eth1/2, [110/81], 01:16:02, ospf-underlay, intra
10.2.1.1/32, ubest/mbest: 1/0
    *via 10.1.1.1, Eth1/1, [110/41], 01:16:14, ospf-underlay, intra
10.2.2.1/32, ubest/mbest: 1/0
    *via 10.1.2.1, Eth1/2, [110/41], 01:16:26, ospf-underlay, intra
10.2.101.1/32, ubest/mbest: 2/0, attached
    *via 10.2.101.1, Lo2, [0/0], 02:08:56, local
    *via 10.2.101.1, Lo2, [0/0], 02:08:56, direct
10.2.103.1/32, ubest/mbest: 2/0
    *via 10.1.1.1, Eth1/1, [110/81], 01:15:59, ospf-underlay, intra
    *via 10.1.2.1, Eth1/2, [110/81], 01:16:02, ospf-underlay, intra
172.16.1.1/32, ubest/mbest: 2/0, attached
    *via 172.16.1.1, Lo3, [0/0], 02:08:56, local
    *via 172.16.1.1, Lo3, [0/0], 02:08:56, direct
172.16.3.1/32, ubest/mbest: 2/0
    *via 10.1.1.1, Eth1/1, [110/81], 01:15:59, ospf-underlay, intra
    *via 10.1.2.1, Eth1/2, [110/81], 01:16:02, ospf-underlay, intra
```

Видим все нужные маршруты

```
leaf01# sh nve peers
Interface Peer-IP                                 State LearnType Uptime   Route
r-Mac       
--------- --------------------------------------  ----- --------- -------- -----
------------
nve1      172.16.3.1                              Up    CP        00:47:50 n/a 
```

Видим в пирах leaf03

```
client01# ping 192.168.0.12
PING 192.168.0.12 (192.168.0.12): 56 data bytes
64 bytes from 192.168.0.12: icmp_seq=0 ttl=254 time=28.472 ms
64 bytes from 192.168.0.12: icmp_seq=1 ttl=254 time=19.808 ms
64 bytes from 192.168.0.12: icmp_seq=2 ttl=254 time=19.046 ms
64 bytes from 192.168.0.12: icmp_seq=3 ttl=254 time=14.771 ms
64 bytes from 192.168.0.12: icmp_seq=4 ttl=254 time=31.579 ms

--- 192.168.0.12 ping statistics ---
5 packets transmitted, 5 packets received, 0.00% packet loss
round-trip min/avg/max = 14.771/22.735/31.579 ms
```

Пинг между клиентами работает
