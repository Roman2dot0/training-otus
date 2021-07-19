#### Underlay. OSPF. Цель:

Настроить OSPF для Underlay сети

В этой самостоятельной работе мы ожидаем, что вы самостоятельно:

    настроить OSPF в Underlay сети, для IP связанности между всеми устройствами.
    План работы, адресное пространство, схема сети, настройки - зафиксированы в документации.

## Решенние:

![Архитектура сети](https://github.com/Roman2dot0/training-otus/blob/master/ex2.%20OSPF/ospf.png)

Тут красным выделена area 0 - она объединяет spine. Зёлёным - stub area с номером leaf.
Соответственно, о полной топологии сети знают только spine, для leaf отдаётся только default route.

MAC адреса для сопоставления имён интерфейсов

unit | MAC addresses range
------------ | -------------
main sw | 44:38:39:00:00:XX
spines | 44:38:39:00:01:XX
leafs | 44:38:39:00:02:XX
clients | 44:38:39:00:03:XX

Примеры ospf таблиц маршрутизации

spine1

```
vagrant@spine1:mgmt:~$ net show ospf route
============ OSPF network routing table ============
N    10.0.0.0/24           [100] area: 0.0.0.0
                           directly attached to swp1
N    10.0.1.0/30           [100] area: 0.0.0.1
                           directly attached to swp2
N    10.0.1.4/30           [200] area: 0.0.0.1
                           via 10.0.1.2, swp2
N IA 10.0.1.8/30           [200] area: 0.0.0.0
                           via 10.0.0.3, swp1
N    10.0.1.12/30          [100] area: 0.0.0.2
                           directly attached to swp3
N    10.0.1.16/30          [200] area: 0.0.0.2
                           via 10.0.1.14, swp3
N    10.0.1.20/30          [100] area: 0.0.0.3
                           directly attached to swp4
N    10.0.1.24/30          [200] area: 0.0.0.3
                           via 10.0.1.22, swp4
N    10.1.0.0/24           [110] area: 0.0.0.1
                           via 10.0.1.2, swp2
                           via 10.0.1.14, swp3
N    10.2.0.0/24           [200] area: 0.0.0.3
                           via 10.0.1.22, swp4
N IA 10.3.0.0/24           [300] area: 0.0.0.0
                           via 10.0.0.3, swp1

============ OSPF router routing table =============
R    172.16.12.12          [200] area: 0.0.0.1, ABR
                           via 10.0.1.2, swp2
                           [200] area: 0.0.0.2, ABR
                           via 10.0.1.14, swp3
                           [200] area: 0.0.0.3, ABR
                           via 10.0.1.22, swp4
                           [100] area: 0.0.0.0, ABR
                           via 10.0.0.2, swp1
R    172.16.12.13          [100] area: 0.0.0.0, ABR
                           via 10.0.0.3, swp1

============ OSPF external routing table ===========
```

leaf1
```
vagrant@leaf1:mgmt:~$ net show ospf route
============ OSPF network routing table ============
N IA 0.0.0.0/0             [101] area: 0.0.0.1
                           via 10.0.1.1, swp2
                           via 10.0.1.5, swp3
N    10.0.1.0/30           [100] area: 0.0.0.1
                           directly attached to swp2
N    10.0.1.4/30           [100] area: 0.0.0.1
                           directly attached to swp3
N    10.1.0.0/24           [10] area: 0.0.0.1
                           directly attached to vlan1

============ OSPF router routing table =============
R    172.16.12.11          [100] area: 0.0.0.1, ABR
                           via 10.0.1.1, swp2
R    172.16.12.12          [100] area: 0.0.0.1, ABR
                           via 10.0.1.5, swp3

============ OSPF external routing table ===========
```

Для простой проверки маршрутизации запускаем ping с client1 до client2/3

```
vagrant@client1:mgmt:~$ ping -c 3 10.2.0.100
vrf-wrapper.sh: switching to vrf "default"; use '--no-vrf-switch' to disable
PING 10.2.0.100 (10.2.0.100) 56(84) bytes of data.
64 bytes from 10.2.0.100: icmp_seq=1 ttl=61 time=2.49 ms
64 bytes from 10.2.0.100: icmp_seq=2 ttl=61 time=2.46 ms
64 bytes from 10.2.0.100: icmp_seq=3 ttl=61 time=2.43 ms

--- 10.2.0.100 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 2.431/2.460/2.490/0.047 ms
vagrant@client1:mgmt:~$ ping -c 3 10.3.0.100
vrf-wrapper.sh: switching to vrf "default"; use '--no-vrf-switch' to disable
PING 10.3.0.100 (10.3.0.100) 56(84) bytes of data.
64 bytes from 10.3.0.100: icmp_seq=1 ttl=60 time=3.47 ms
64 bytes from 10.3.0.100: icmp_seq=2 ttl=60 time=3.68 ms
64 bytes from 10.3.0.100: icmp_seq=3 ttl=60 time=3.79 ms

--- 10.3.0.100 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 3.471/3.647/3.788/0.131 ms

```
