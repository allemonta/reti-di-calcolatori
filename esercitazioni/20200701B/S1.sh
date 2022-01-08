vlan/create 10
vlan/create 20

vlan/addport 10 5
vlan/addport 20 5

port/setvlan 1 10
port/setvlan 2 10
port/setvlan 3 20
port/setvlan 4 20