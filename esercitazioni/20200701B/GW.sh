
echo "

auto lo
iface lo inet loopback

auto eth0.10
iface eth0.10 inet static
    address 192.168.10.254/24
    post-up iptables -t nat -A POSTROUTING -o eth0.10 -j MASQUERADE

auto eth0.20
iface eth0.20 inet static
    address 192.168.20.254/24
    post-up iptables -t nat -A POSTROUTING -o eth0.20 -j MASQUERADE


" >> /etc/network/interfaces


sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
sysctl -p /etc/sysctl.conf


tc qdisc add dev eth0.10 root tbf rate 1Mbit latency 50ms burst 1539
tc qdisc add dev eth0.20 root tbf rate 1Mbit latency 50ms burst 1539
