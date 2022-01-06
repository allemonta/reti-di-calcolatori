
echo "

auto lo
iface lo inet loopback

auto eth0.10
iface eth0.10 inet static
    address 10.0.10.254/24

auto eth0.20
iface eth0.20 inet static
    address 10.0.20.254/24

auto eth1
iface eth1 inet static
    address 1.1.1.1/32
    post-up iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
    post-up iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 80 -j DNAT --to-destination 10.0.10.1:80
    post-up iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 8080 -j DNAT --to-destination 10.0.20.1:80
    post-up route add -host 2.2.2.2 dev eth1


" >> /etc/network/interfaces


apt install isc-dhcp-server

sed -i "s/INTERFACES=\"\"/INTERFACES=\"eth0.10 eth0.20\"/g" /etc/default/isc-dhcp-server


sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
sysctl -p /etc/sysctl.conf


echo "

authoritative;
shared-network 10-0-10 {
    subnet 10.0.10.0 netmask 255.255.255.0 {
        option routers 10.0.10.254;
    }
}

shared-network 10-0-20 {
    subnet 10.0.20.0 netmask 255.255.255.0 {
        option routers 10.0.20.254;
    }
}

host Srv1 {
    hardware ethernet 02:04:06:11:22:33;
    fixed-address 10.0.10.1;
}

host Srv2 {
    hardware ethernet 02:04:06:11:22:44;
    fixed-address 10.0.20.1;
}


" >> /etc/dhcp/dhcpd.conf

service isc-dhcp-server start
systemctl enable isc-dhcp-server

