
echo "

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.1.254/24

auto eth1
iface eth1 inet static
    address 1.1.1.1/32
    post-up iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
    post-up iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1:80
    post-up iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 25 -j DNAT --to-destination 192.168.1.2:25
    post-up route add -host 2.2.2.2 dev eth1


" >> /etc/network/interfaces


sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
sysctl -p /etc/sysctl.conf



