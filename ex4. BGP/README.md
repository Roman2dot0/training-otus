#### Underlay. BGP. Цель:

Настроить BGP для Underlay сети

В этой самостоятельной работе мы ожидаем, что вы самостоятельно:

    настроить BGP в Underlay сети, для IP связанности между всеми устройствами
    План работы, адресное пространство, схема сети, настройки - зафиксированы в документации



## Решенние:

![Архитектура сети](https://github.com/Roman2dot0/training-otus/blob/master/ex4.%20BGP/bgp.png)

Разделим сеть на 2 основных сегмента: первый включает в себя spine1, spine2 и все подключенные к ним leaf; второй - spine3 + leaf4.
Объединяем spine в сегментах в одну AS (уникальная на сегмент), на каждый leaf назначаем уникальную AS. mainSw участвует в BGP топологии и служит для имитации связности через Интернет. Для упрощения настройки будут использоваться unnumbered ip внутри сегментов.
Т.к клиенты находятся за leaf, то анонс сетей будет только с них и только клиентских сетей. В этом случае будет работать маршрутизация между клиентами, но не между остальными участниками. [Документация по настройке BGP.](https://docs.nvidia.com/networking-ethernet-software/cumulus-linux-44/Layer-3/Border-Gateway-Protocol-BGP/Basic-BGP-Configuration/)


Для простой проверки маршрутизации запускаем ping с client1 до client2/3

```
vagrant@client1:mgmt:~$ ping -c 3 10.2.0.100
vrf-wrapper.sh: switching to vrf "default"; use '--no-vrf-switch' to disable
PING 10.2.0.100 (10.2.0.100) 56(84) bytes of data.
64 bytes from 10.2.0.100: icmp_seq=1 ttl=61 time=2.34 ms
64 bytes from 10.2.0.100: icmp_seq=2 ttl=61 time=2.65 ms
64 bytes from 10.2.0.100: icmp_seq=3 ttl=61 time=2.81 ms

--- 10.2.0.100 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 6ms
rtt min/avg/max/mdev = 2.343/2.600/2.810/0.202 ms
vagrant@client1:mgmt:~$ ping -c 3 10.3.0.100
vrf-wrapper.sh: switching to vrf "default"; use '--no-vrf-switch' to disable
PING 10.3.0.100 (10.3.0.100) 56(84) bytes of data.
64 bytes from 10.3.0.100: icmp_seq=1 ttl=60 time=3.77 ms
64 bytes from 10.3.0.100: icmp_seq=2 ttl=60 time=3.70 ms
64 bytes from 10.3.0.100: icmp_seq=3 ttl=60 time=3.79 ms

--- 10.3.0.100 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 6ms
rtt min/avg/max/mdev = 3.696/3.753/3.794/0.041 ms
```

Пример того, что работает BGP Multipath. Nexthop объедняются в группу и автоматически работает ECMP для таких маршрутов.

leaf3 в сторону сети за leaf1, leaf2
```
root@leaf3:mgmt:~# ip route show 10.1.0.0/24
10.1.0.0/24 nhid 24 proto bgp metric 20
root@leaf3:mgmt:~#
root@leaf3:mgmt:~#
root@leaf3:mgmt:~# ip nexthop show
id 11 dev lo scope host proto zebra
id 12 dev eth0 scope host proto zebra
id 13 dev swp3 scope host proto zebra
id 14 dev eth0 scope link proto zebra
id 17 dev swp1 scope link proto zebra
id 19 via 10.255.1.1 dev eth0 scope link proto zebra
id 20 blackhole proto zebra
id 24 group 25/26 proto zebra
id 25 via fe80::4638:39ff:fe00:104 dev swp1 scope link proto zebra
id 26 via fe80::4638:39ff:fe00:108 dev swp2 scope link proto zebra
```

leaf1 в сторону сети за leaf4
```
vagrant@leaf1:mgmt:~$ ip route show 10.3.0.0/24
10.3.0.0/24 nhid 30 proto bgp metric 20
vagrant@leaf1:mgmt:~$
vagrant@leaf1:mgmt:~$
vagrant@leaf1:mgmt:~$ ip nexthop show
id 9 dev lo scope host proto zebra
id 10 dev eth0 scope host proto zebra
id 11 dev eth0 scope link proto zebra
id 13 dev swp2 scope link proto zebra
id 15 via 10.255.1.1 dev eth0 scope link proto zebra
id 16 blackhole proto zebra
id 26 dev vlan1 scope host proto zebra
id 30 group 31/32 proto zebra
id 31 via fe80::4638:39ff:fe00:102 dev swp2 scope link proto zebra
id 32 via fe80::4638:39ff:fe00:106 dev swp3 scope link proto zebra
```

Пример BGP таблицы на mainSw
```
vagrant@mainSw:mgmt:~$ net show bgp
show bgp ipv4 unicast
=====================
BGP table version is 3, local router ID is 172.16.12.1, vrf id 0
Default local pref 100, local AS 65000
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*= 10.1.0.0/24      10.0.0.2                               0 65100 65101 i
*>                  10.0.0.1                               0 65100 65101 i
*= 10.2.0.0/24      10.0.0.2                               0 65100 65103 i
*>                  10.0.0.1                               0 65100 65103 i
*> 10.3.0.0/24      10.0.0.3                               0 65200 65201 i

Displayed  3 routes and 5 total paths


show bgp ipv6 unicast
=====================
No BGP prefixes displayed, 0 exist
```
