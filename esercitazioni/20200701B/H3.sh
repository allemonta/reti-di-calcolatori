
echo "

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.20.1/24
    gateway 192.168.20.254


" >> /etc/network/interfaces




