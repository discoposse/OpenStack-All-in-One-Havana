sudo sed -i "s/ubuntu/aio-havana/g" /etc/hosts

rm /etc/network/interfaces
echo "
# localhost
auto lo
iface lo inet loopback

# public IP
auto eth0
iface eth0 inet static
	address 192.168.79.50
	netmask 255.255.255.0
	gateway 192.168.79.2
	dns-nameservers 8.8.8.8

auto eth1
iface eth1 inet manual
	up ifconfig $IFACE 0.0.0.0 up
	up ifconfig $IFACE promisc
" > /etc/network/interfaces

reboot
