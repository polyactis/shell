echo 1 >/proc/sys/net/ipv4/ip_forward
echo 1 >/proc/sys/net/ipv4/ip_dynaddr
iptables -t nat -P POSTROUTING ACCEPT 
iptables -t nat -A POSTROUTING  -s 10.100.113.147/32 -d ! 10.0.0.0/8 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth1 -s 10.100.113.60/32 -d ! 10.0.0.0/8 -j MASQUERADE  
iptables -t nat -A POSTROUTING -o eth1 -s 10.100.113.96/32 -d ! 10.0.0.0/8 -j MASQUERADE
