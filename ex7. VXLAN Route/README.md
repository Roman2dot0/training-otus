![Архитектура сети](https://github.com/Roman2dot0/training-otus/blob/master/ex7.%20VXLAN%20Route/vxlan_route.png)   
В этой работе добавляются следующие ip    
unit | port | IP addresses
------------ | ------------- | -----------
leaf 1 | vlan20 | 192.168.20.1/24
leaf 1 | eth1/3 | 10.255.255.1/24
leaf 1 | lo3 | 172.31.255.1/32 secondary
leaf 2 | vlan20 | 192.168.20.1/24
leaf 2 | eth1/3 | 10.255.255.2/24
leaf 2 | lo3 | 172.31.255.1/32 secondary
leaf 3 | vlan30 | 192.168.30.1/24
client 1 | vlan20 | 192.168.20.11/24
client 2 | vlan30 | 192.168.30.12/24
    
В данной работе нужно настроить l3 связность между client01 и client02 посредством evpn. Так же настроить vpc+lacp для clint1.    
Для тестов создадим vlan 20 и 30 на client1 и clien2 соответственно. В качестве шлюзов будут выступать leaf. Для корректной работы vpc нужно будет задать anycast-gateway-mac 0000.0000.1111.    
На client создаём vlan и маршрут по умолчанию, пример    
```sh
vlan 30
no spanning-tree vlan 30
interface vlan 30
  ip address 192.168.30.12/24
  no shutdown

ip route 0.0.0.0/0 192.168.30.1
```    

Vlan для маршрутизации на leaf будет vlan 2030, vni 92030, vrf router20to30    
В качестве всех устройств используется cisco nexus 9000v (9.3.8).    
На клиентах отключается stp для vlan, иначе интерфейсы vlan будут в состоянии down.        
Настройки лежат в configs. Проверяем, что всё работает    


```
leaf01# sh ip route vrf router20to30 
IP Route Table for VRF "router20to30"
'*' denotes best ucast next-hop
'**' denotes best mcast next-hop
'[x/y]' denotes [preference/metric]
'%<string>' in via output denotes VRF <string>

192.168.20.0/24, ubest/mbest: 1/0, attached
    *via 192.168.20.1, Vlan20, [0/0], 00:36:48, direct
192.168.20.1/32, ubest/mbest: 1/0, attached
    *via 192.168.20.1, Vlan20, [0/0], 00:36:48, local
192.168.20.11/32, ubest/mbest: 1/0, attached
    *via 192.168.20.11, Vlan20, [190/0], 00:35:44, hmm
192.168.30.12/32, ubest/mbest: 1/0
    *via 172.16.3.1%default, [200/0], 00:36:37, bgp-65000, internal, tag 65000, 
segid: 92030 tunnelid: 0xac100301 encap: VXLAN

```

Видим маршрут до client2 в vrf router20to30 через leaf3    


```
leaf03# sh nve vni 
Codes: CP - Control Plane        DP - Data Plane          
       UC - Unconfigured         SA - Suppress ARP        
       SU - Suppress Unknown Unicast 
       Xconn - Crossconnect      
       MS-IR - Multisite Ingress Replication
 
Interface VNI      Multicast-group   State Mode Type [BD/VRF]      Flags
--------- -------- ----------------- ----- ---- ------------------ -----
nve1      10010    UnicastBGP        Up    CP   L2 [10]                 
nve1      10030    UnicastBGP        Up    CP   L2 [30]                 
nve1      92030    n/a               Up    CP   L3 [router20to30]
```

vni на leaf03    

```
leaf03# sh nve peers 
Interface Peer-IP                                 State LearnType Uptime   Router-Mac       
--------- --------------------------------------  ----- --------- -------- -----------------
nve1      172.31.255.1                            Up    CP        00:16:10 5005.0000.1b08
```    

Изменения после настройки vpc и secondary ip для nve    
    
```
leaf02# sh vpc
Legend:
                (*) - local vPC is down, forwarding via vPC peer-link

vPC domain id                     : 1   
Peer status                       : peer adjacency formed ok      
vPC keep-alive status             : peer is alive                 
Configuration consistency status  : success 
Per-vlan consistency status       : success                       
Type-2 consistency status         : success 
vPC role                          : secondary                     
Number of vPCs configured         : 1   
Peer Gateway                      : Disabled
Dual-active excluded VLANs        : -
Graceful Consistency Check        : Enabled
Auto-recovery status              : Disabled
Delay-restore status              : Timer is off.(timeout = 30s)
Delay-restore SVI status          : Timer is off.(timeout = 10s)
Operational Layer3 Peer-router    : Disabled
Virtual-peerlink mode             : Disabled

vPC Peer-link status
---------------------------------------------------------------------
id    Port   Status Active vlans    
--    ----   ------ -------------------------------------------------
1     Po100  up     1,10,20,2030                                                
         

vPC status
----------------------------------------------------------------------------
Id    Port          Status Consistency Reason                Active vlans
--    ------------  ------ ----------- ------                ---------------
200   Po200         up     success     success               1,10,20,2030       
```    

Убеждаемся, что vpc настроен и работает    

```
client01# ping 192.168.30.12
PING 192.168.30.12 (192.168.30.12): 56 data bytes
64 bytes from 192.168.30.12: icmp_seq=0 ttl=252 time=20.07 ms
64 bytes from 192.168.30.12: icmp_seq=1 ttl=252 time=13.432 ms
64 bytes from 192.168.30.12: icmp_seq=2 ttl=252 time=15.804 ms
64 bytes from 192.168.30.12: icmp_seq=3 ttl=252 time=17.055 ms
64 bytes from 192.168.30.12: icmp_seq=4 ttl=252 time=13.742 ms

--- 192.168.30.12 ping statistics ---
5 packets transmitted, 5 packets received, 0.00% packet loss
round-trip min/avg/max = 13.432/16.02/20.07 ms
```

Пинг между клиентами работает
