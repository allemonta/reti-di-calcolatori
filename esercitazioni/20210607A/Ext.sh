
echo "

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 2.2.2.2/32
    post-up route add -host 1.1.1.1 dev eth0


" >> /etc/network/interfaces


