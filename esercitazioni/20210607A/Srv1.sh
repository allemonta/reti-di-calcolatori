
echo "

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
    hwaddress ether 02:04:06:11:22:33


" >> /etc/network/interfaces


