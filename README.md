# Домашнее задание к занятию 1 «Disaster recovery и Keepalived»

### Цель задания
В результате выполнения этого задания вы научитесь:
1. Настраивать отслеживание интерфейса для протокола HSRP;
2. Настраивать сервис Keepalived для использования плавающего IP
---
### Задание 1
- Дана [схема](1/hsrp_advanced.pkt) для Cisco Packet Tracer, рассматриваемая в лекции.
- На данной схеме уже настроено отслеживание интерфейсов маршрутизаторов Gi0/1 (для нулевой группы)
- Необходимо аналогично настроить отслеживание состояния интерфейсов Gi0/0 (для первой группы).
- Для проверки корректности настройки, разорвите один из кабелей между одним из маршрутизаторов и Switch0 и запустите ping между PC0 и Server0.
- На проверку отправьте получившуюся схему в формате pkt и скриншот, где виден процесс настройки маршрутизатора.
---
### Решение 1
![image](https://github.com/jinnonn/netology-keepalived-hw/assets/146999555/f9a54a7c-4777-4f4d-90b1-38467344f81e)

- Схема в формате pkt лежит в данном репозитории.
---
### Задание 2
- Запустите две виртуальные машины Linux, установите и настройте сервис Keepalived как в лекции, используя пример конфигурационного [файла](1/keepalived-simple.conf).
- Настройте любой веб-сервер (например, nginx или simple python server) на двух виртуальных машинах
- Напишите Bash-скрипт, который будет проверять доступность порта данного веб-сервера и существование файла index.html в root-директории данного веб-сервера.
- Настройте Keepalived так, чтобы он запускал данный скрипт каждые 3 секунды и переносил виртуальный IP на другой сервер, если bash-скрипт завершался с кодом, отличным от нуля (то есть порт веб-сервера был недоступен или отсутствовал index.html). Используйте для этого секцию vrrp_script
- На проверку отправьте получившейся bash-скрипт и конфигурационный файл keepalived, а также скриншот с демонстрацией переезда плавающего ip на другой сервер в случае недоступности порта или файла index.html

---
### Решение 2
bash:
```
#!/bin/bash

curl localhost &> /dev/null
if [ "$?" -ne 0 ]; then exit 1; fi
if [ ! -f "/var/www/html/index.nginx-debian.html" ]; then exit 1; fi
```
keepalive master:
```
global_defs {
    enable_script_security
}

vrrp_script check_nginx {
        script "/home/jinon/netcheck.sh"
        interval 3
        user jinon
}

vrrp_instance VI_1 {
        state MASTER
        interface ens33
        virtual_router_id 5
        priority 110
        advert_int 1

        virtual_ipaddress {
              192.200.0.150/24
        }

        track_script {
                   check_nginx
        }
}
```
keepalive BACKUP:
```
global_defs {
    enable_script_security
}

vrrp_script check_nginx {
        script "/home/jinon/netcheck.sh"
        interval 3
        user jinon
}

vrrp_instance VI_1 {
        state BACKUP
        interface ens33
        virtual_router_id 5
        priority 100
        advert_int 1

        virtual_ipaddress {
              192.200.0.150/24
        }

        track_script {
                   check_nginx
        }
}
```
#### До "падения" мастера:

![image](https://github.com/jinnonn/netology-keepalived-hw/assets/146999555/660dfe50-3ed3-4f37-ac62-8df7ef6519b6)
![image](https://github.com/jinnonn/netology-keepalived-hw/assets/146999555/c61b5ce5-85a9-42d3-a09c-ed2127df74b7)
#### После "падения" мастера:

![image](https://github.com/jinnonn/netology-keepalived-hw/assets/146999555/660dfe50-3ed3-4f37-ac62-8df7ef6519b6)
![image](https://github.com/jinnonn/netology-keepalived-hw/assets/146999555/a2f2a6e1-ad17-4742-b0ed-e0f8a7a1d8e4)


