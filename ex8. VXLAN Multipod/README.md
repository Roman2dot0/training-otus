![Архитектура сети](https://github.com/Roman2dot0/training-otus/blob/master/ex8.%20VXLAN%20Multipod/vxlan_multipod.png)   
В этой работе добавляются следующие ip    
unit | port | IP addresses
------------ | ------------- | -----------
leaf 4 | vlan40 | 192.168.40.1/24
client 3 | vlan40 | 192.168.40.13/24 
    
В данной работе нужно настроить l3 и l2 связность между client01, client02 и client03 посредством evpn.    
L2 связность будет в vlan 10, в котором уже есть есть клиенты 1, 2.    
L3 связность будет между текущими vlan 20, 30 и новым 40 на client03. Для машрутизации на leaf будет создан vrf router-vxlan, vni 9999, vlan 999.    
mainsw выступает тут в 2 ролях:    
1. without SS - mainsw работает как простой роутер с ospf, сесссии BGP настроены между spine    
2. with SS - mainsw настроен как super spine с AS65200    

Специфичные файлы конфигурации вынесены в отдельные директории    

Для всех spine и leaf включен параметр ![rewrite-evpn-rt-asn](https://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/7-x/command_references/configuration_commands/b_N9K_Config_Commands_703i7x/b_N9K_Config_Commands_703i7x_chapter_010010.html#wp4498893710), он нужен если route-target задаётся auto, а не вручную, нужен для корректного переписывания AS:VNI при прохождении через другие AS. ![Немного документации, искать About Route-Target Auto](https://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/7-x/vxlan/configuration/guide/b_Cisco_Nexus_9000_Series_NX-OS_VXLAN_Configuration_Guide_7x/b_Cisco_Nexus_9000_Series_NX-OS_VXLAN_Configuration_Guide_7x_chapter_0100.html)    
Для всех spine задаются параметры:    
- ebgp-multihop, т.к в системе будет multihop    
- route-map в которой ip next-hop unchanged, чтобы не подставлять адрес промежуточного super spine     

В качестве всех устройств используется cisco nexus 9000v (9.3.8).           
Настройки лежат в configs. Проверяем, что всё работает    


```
leaf01# sh ip route vrf router-vxlan 
IP Route Table for VRF "router-vxlan"
'*' denotes best ucast next-hop
'**' denotes best mcast next-hop
'[x/y]' denotes [preference/metric]
'%<string>' in via output denotes VRF <string>

192.168.20.0/24, ubest/mbest: 1/0, attached
    *via 192.168.20.1, Vlan20, [0/0], 01:47:22, direct
192.168.20.1/32, ubest/mbest: 1/0, attached
    *via 192.168.20.1, Vlan20, [0/0], 01:47:22, local
192.168.20.11/32, ubest/mbest: 1/0, attached
    *via 192.168.20.11, Vlan20, [190/0], 00:53:48, hmm
192.168.30.12/32, ubest/mbest: 1/0
    *via 172.16.3.1%default, [200/0], 00:19:56, bgp-65000, internal, tag 65000, 
segid: 9999 tunnelid: 0xac100301 encap: VXLAN
 
192.168.40.13/32, ubest/mbest: 1/0
    *via 172.16.4.1%default, [200/0], 00:13:13, bgp-65000, internal, tag 65200, 
segid: 9999 tunnelid: 0xac100401 encap: VXLAN

```

Видим маршрут до client2 и client3 в vrf router-vxlan через leaf3 и leaf4 соответственно        


```
leaf01# sh nve peers 
Interface Peer-IP                                 State LearnType Uptime   Router-Mac       
--------- --------------------------------------  ----- --------- -------- -----------------
nve1      172.16.3.1                              Up    CP        01:27:20 5007.0000.1b08   
nve1      172.16.4.1                              Up    CP        00:15:00 5008.0000.1b08   


leaf04# sh nve peers 
Interface Peer-IP                                 State LearnType Uptime   Router-Mac       
--------- --------------------------------------  ----- --------- -------- -----------------
nve1      172.16.3.1                              Up    CP        00:15:38 5007.0000.1b08   
nve1      172.31.255.1                            Up    CP        00:15:38 5005.0000.1b08  

```

пример nve peer на leaf в разных подах. VPC пара представлена 1 адресом (172.31.255.1)    
 

```
client03# ping 192.168.0.11
PING 192.168.0.11 (192.168.0.11): 56 data bytes
64 bytes from 192.168.0.11: icmp_seq=0 ttl=254 time=23.098 ms
64 bytes from 192.168.0.11: icmp_seq=1 ttl=254 time=27.853 ms
64 bytes from 192.168.0.11: icmp_seq=2 ttl=254 time=28.735 ms
64 bytes from 192.168.0.11: icmp_seq=3 ttl=254 time=25.82 ms
64 bytes from 192.168.0.11: icmp_seq=4 ttl=254 time=26.927 ms

--- 192.168.0.11 ping statistics ---
5 packets transmitted, 5 packets received, 0.00% packet loss
round-trip min/avg/max = 23.098/26.486/28.735 ms
client03# ping 192.168.0.12
PING 192.168.0.12 (192.168.0.12): 56 data bytes
64 bytes from 192.168.0.12: icmp_seq=0 ttl=254 time=26.96 ms
64 bytes from 192.168.0.12: icmp_seq=1 ttl=254 time=18.421 ms
64 bytes from 192.168.0.12: icmp_seq=2 ttl=254 time=27.149 ms
64 bytes from 192.168.0.12: icmp_seq=3 ttl=254 time=26.085 ms
64 bytes from 192.168.0.12: icmp_seq=4 ttl=254 time=27.024 ms

--- 192.168.0.12 ping statistics ---
5 packets transmitted, 5 packets received, 0.00% packet loss
round-trip min/avg/max = 18.421/25.127/27.149 ms
client03# ping 192.168.20.11
PING 192.168.20.11 (192.168.20.11): 56 data bytes
64 bytes from 192.168.20.11: icmp_seq=0 ttl=252 time=29.64 ms
64 bytes from 192.168.20.11: icmp_seq=1 ttl=252 time=26.47 ms
64 bytes from 192.168.20.11: icmp_seq=2 ttl=252 time=31.014 ms
64 bytes from 192.168.20.11: icmp_seq=3 ttl=252 time=24.518 ms
64 bytes from 192.168.20.11: icmp_seq=4 ttl=252 time=28.094 ms

--- 192.168.20.11 ping statistics ---
5 packets transmitted, 5 packets received, 0.00% packet loss
round-trip min/avg/max = 24.518/27.947/31.014 ms
client03# ping 192.168.30.12
PING 192.168.30.12 (192.168.30.12): 56 data bytes
64 bytes from 192.168.30.12: icmp_seq=0 ttl=252 time=20.674 ms
64 bytes from 192.168.30.12: icmp_seq=1 ttl=252 time=18.166 ms
64 bytes from 192.168.30.12: icmp_seq=2 ttl=252 time=19.171 ms
64 bytes from 192.168.30.12: icmp_seq=3 ttl=252 time=19.84 ms
64 bytes from 192.168.30.12: icmp_seq=4 ttl=252 time=24.533 ms

--- 192.168.30.12 ping statistics ---
5 packets transmitted, 5 packets received, 0.00% packet loss
round-trip min/avg/max = 18.166/20.476/24.533 ms

```

Пинг от client3 в сторону clien2 и client1. Первые 2 - в одном l2 сегменте, vlan10. Последующие 2 - в другие сети
