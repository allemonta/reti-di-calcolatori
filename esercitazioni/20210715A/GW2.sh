
echo "

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.2.254/24

auto eth1
iface eth1 inet static
    address 2.2.2.2/32
    post-up iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
    post-up route add -host 1.1.1.1 dev eth1


" >> /etc/network/interfaces


sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
sysctl -p /etc/sysctl.conf



