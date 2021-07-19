#### Underlay. ISIS. Цель:

Настроить IS-IS для Underlay сети

В этой самостоятельной работе мы ожидаем, что вы самостоятельно:

    Настроить IS-IS в Underlay сети, для IP связанности между всеми устройствами
    План работы, адресное пространство, схема сети, настройки - зафиксированы в документации


## Решенние:

![Архитектура сети](https://github.com/Roman2dot0/training-otus/blob/master/ex3.%20IS-IS/isis.png)

Для упрощения построения топологии разделим сеть на 2 area. Для соединения между area будет использоваться уровень L2, внутри area - L1. mainSw не будет участвовать в ISIS топологии и нужен только в качестве простого L2 коммутатора.
Cumulus Linux не поддерживает настройку ISIS через nclu, но использует в работе [FRR](https://frrouting.org). Настраивать будем напрямую, через файлы конфигурации и консоль [vtysh](https://docs.frrouting.org/en/latest/vtysh.html).


Пинг между клиентами
```
vagrant@client1:mgmt:~$ ping -c 3 10.2.0.100
vrf-wrapper.sh: switching to vrf "default"; use '--no-vrf-switch' to disable
PING 10.2.0.100 (10.2.0.100) 56(84) bytes of data.
64 bytes from 10.2.0.100: icmp_seq=1 ttl=61 time=3.99 ms
64 bytes from 10.2.0.100: icmp_seq=2 ttl=61 time=2.61 ms
64 bytes from 10.2.0.100: icmp_seq=3 ttl=61 time=2.62 ms

--- 10.2.0.100 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 6ms
rtt min/avg/max/mdev = 2.613/3.075/3.989/0.647 ms
vagrant@client1:mgmt:~$ ping -c 3 10.3.0.100
vrf-wrapper.sh: switching to vrf "default"; use '--no-vrf-switch' to disable
PING 10.3.0.100 (10.3.0.100) 56(84) bytes of data.
64 bytes from 10.3.0.100: icmp_seq=1 ttl=60 time=5.06 ms
64 bytes from 10.3.0.100: icmp_seq=2 ttl=60 time=4.31 ms
64 bytes from 10.3.0.100: icmp_seq=3 ttl=60 time=4.24 ms

--- 10.3.0.100 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 5ms
rtt min/avg/max/mdev = 4.239/4.536/5.058/0.370 ms
```

Пример сосоедей spine2
```
vagrant@spine2:mgmt:~$ sudo vtysh -c 'show isis neighbor'
Area spine2:
  System Id           Interface   L  State        Holdtime SNPA
  spine3              swp1        2  Up           28       4438.3900.0109
  spine1              swp1        2  Up           28       4438.3900.0101
  leaf1               swp2        1  Up           28       4438.3900.0203
  leaf1               swp2        2  Up           29       4438.3900.0203
  leaf2               swp3        1  Up           28       4438.3900.0207
  leaf2               swp3        2  Up           28       4438.3900.0207
  leaf3               swp4        2  Up           29       4438.3900.0210
```

Таблица маршрутизации на leaf4
```
vagrant@leaf4:mgmt:~$ ip r
10.0.0.0/24 nhid 22 proto isis metric 20
10.0.1.0/30 nhid 22 proto isis metric 20
10.0.1.4/30 nhid 22 proto isis metric 20
10.0.1.8/30 dev swp1 proto kernel scope link src 10.0.1.10
10.0.1.12/30 nhid 22 proto isis metric 20
10.0.1.16/30 nhid 22 proto isis metric 20
10.0.1.20/30 nhid 22 proto isis metric 20
10.0.1.24/30 nhid 22 proto isis metric 20
10.1.0.0/24 nhid 22 proto isis metric 20
10.2.0.0/24 nhid 22 proto isis metric 20
10.3.0.0/24 dev swp2 proto kernel scope link src 10.3.0.1
```
