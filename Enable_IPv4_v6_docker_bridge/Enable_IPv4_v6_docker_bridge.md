
# Docker bridge enable IPv4 and IPv6

# Description

Here is how to enalbe both IPv4 and IPv6 on docker bridge.
My host machine does not have global IPv6 addresses, so can use IPv6 internally.

# Create a docker bridge by enabling IPv4 and IPv6.

```
$ docker network create --driver bridge --ipv6 --subnet=fd5a:ceb9:ed8d:1::/64 --subnet 172.31.0.0/24 br_v4_v6
```

# Confirmation

start a container.
I can see both IPv4 and IPv6 are assined to the container.
```
$ docker container run -it -d --network br_v4_v6 ubuntu:latest

$ docker exec -it naughty_faraday bash

root@49a52c2c5228:/# apt update ;apt install -y iproute2 iputils-ping

root@49a52c2c5228:/# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
26: eth0@if27: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:1f:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.31.0.2/24 brd 172.31.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fd5a:ceb9:ed8d:1::2/64 scope global nodad 
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe1f:2/64 scope link 
       valid_lft forever preferred_lft forever
root@49a52c2c5228:/# 
```

run one more container to confirm IPv6 reachability.
```
$ docker exec quizzical_chebyshev ip a s eth0
28: eth0@if29: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:1f:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.31.0.3/24 brd 172.31.0.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fd5a:ceb9:ed8d:1::3/64 scope global nodad 
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe1f:3/64 scope link 
       valid_lft forever preferred_lft forever
```

send ping6 between two conainers.
```
root@57892b94bd62:/# ip -6 a s eth0
30: eth0@if31: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default  link-netnsid 0
    inet6 fd5a:ceb9:ed8d:1::3/64 scope global nodad 
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe1f:3/64 scope link 
       valid_lft forever preferred_lft forever

root@57892b94bd62:/# ping6 -I eth0 fd5a:ceb9:ed8d:1::2 -c3
PING fd5a:ceb9:ed8d:1::2(fd5a:ceb9:ed8d:1::2) from fd5a:ceb9:ed8d:1::3 eth0: 56 data bytes
64 bytes from fd5a:ceb9:ed8d:1::2: icmp_seq=1 ttl=64 time=0.189 ms
64 bytes from fd5a:ceb9:ed8d:1::2: icmp_seq=2 ttl=64 time=0.110 ms
64 bytes from fd5a:ceb9:ed8d:1::2: icmp_seq=3 ttl=64 time=0.107 ms

--- fd5a:ceb9:ed8d:1::2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2049ms
rtt min/avg/max/mdev = 0.107/0.135/0.189/0.037 ms
```

send ping(ipv4) between two conainers.
```
root@57892b94bd62:/# ip -4 a s eth0
30: eth0@if31: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default  link-netnsid 0
    inet 172.31.0.3/24 brd 172.31.0.255 scope global eth0
       valid_lft forever preferred_lft forever
root@57892b94bd62:/# ping 172.31.0.2 -c1
PING 172.31.0.2 (172.31.0.2) 56(84) bytes of data.
64 bytes from 172.31.0.2: icmp_seq=1 ttl=64 time=0.160 ms

--- 172.31.0.2 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.160/0.160/0.160/0.000 ms
root@57892b94bd62:/# 
```

send ping6 against the default gateway.
```
root@57892b94bd62:/# ip -6 r s
fd5a:ceb9:ed8d:1::/64 dev eth0 proto kernel metric 256 pref medium
fe80::/64 dev eth0 proto kernel metric 256 pref medium
default via fd5a:ceb9:ed8d:1::1 dev eth0 metric 1024 pref medium

root@57892b94bd62:/# ping6 -Ieth0 fd5a:ceb9:ed8d:1::1 -c1
PING fd5a:ceb9:ed8d:1::1(fd5a:ceb9:ed8d:1::1) from fd5a:ceb9:ed8d:1::3 eth0: 56 data bytes
64 bytes from fd5a:ceb9:ed8d:1::1: icmp_seq=1 ttl=64 time=0.208 ms

--- fd5a:ceb9:ed8d:1::1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.208/0.208/0.208/0.000 ms
root@57892b94bd62:/# 
```