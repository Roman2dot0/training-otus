#### Underlay. OSPF. Цель:

Настроить OSPF для Underlay сети

В этой самостоятельной работе мы ожидаем, что вы самостоятельно:

    настроить OSPF в Underlay сети, для IP связанности между всеми устройствами.
    План работы, адресное пространство, схема сети, настройки - зафиксированы в документации.

## Решенние:

[Архитектура сети](https://github.com/Roman2dot0/training-otus/blob/master/ex1/README.md)

MAC адреса для сопоставления имён интерфейсов

unit | MAC addresses range
------------ | -------------
main sw | 44:38:39:00:00:XX
spines | 44:38:39:00:01:XX
leafs | 44:38:39:00:02:XX
clients | 44:38:39:00:03:XX


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
