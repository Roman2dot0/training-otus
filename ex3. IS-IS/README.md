#### Underlay. ISIS. Цель:

Настроить IS-IS для Underlay сети

В этой самостоятельной работе мы ожидаем, что вы самостоятельно:

    Настроить IS-IS в Underlay сети, для IP связанности между всеми устройствами
    План работы, адресное пространство, схема сети, настройки - зафиксированы в документации


## Решенние:

![Архитектура сети](https://github.com/Roman2dot0/training-otus/blob/master/ex3/isis.png)

Для упрощения построения топологии разделим сеть на 2 area. Для соединения между area будет использоваться уровень L2, внутри area - L1. mainSw не будет участвовать в ISIS топологии и нужен только в качестве простого L2 коммутатора.
Cumulus Linux не поддерживает настройку ISIS через nclu, но использует в работе [FRR](https://frrouting.org). Настраивать будем напрямую, через файлы конфигурации и консоль [vtysh](https://docs.frrouting.org/en/latest/vtysh.html).