const { writeFileSync, readFileSync, existsSync, mkdirSync } = require("fs")
const { join } = require("path")

const input = JSON.parse(readFileSync("input.json", "utf-8"))
const outFolderPath = join(__dirname, "out")

if (!existsSync(outFolderPath)) {
    mkdirSync(outFolderPath)
} 

Object.entries(input).forEach(([hostName, host]) => {
    let interfaceCode = "auto lo\n"
    interfaceCode += "iface lo inet loopback\n\n"
    
    let dhcpCode = ""

    let natting = false

    Object.entries(host.interfaces).forEach(([interfaceName, interface]) => {
        interfaceCode += `auto ${interfaceName}\n`

        if (interface.type === "static") {
            interfaceCode += `iface ${interfaceName} inet static\n` 
            interfaceCode += `\taddress ${interface.address}\n`
            interfaceCode += interface.gateway ? `\tgateway ${interface.gateway}\n` : ""
        } else if (interface.type === "dhcp") {
            interfaceCode += `iface ${interfaceName} inet dhcp\n`
            interfaceCode += `\thwaddress ether ${interface.macaddress}\n`
        }

        if (interface.snat) {
            natting = true
            interfaceCode += `\tpost-up iptables -t nat -A POSTROUTING -o ${interfaceName} -j MASQUERADE\n`
        }

        if (interface.dnat) {
            natting = true
            interface.dnat.forEach((settings) => {
                interfaceCode += `\tpost-up iptables -t nat -A PREROUTING -i ${interfaceName} -p ${settings.protocol || "tcp"} --dport ${settings.externalPort} -j DNAT --to-destination ${settings.internalIp}:${settings.internalPort}\n`
            })
        }

        interface.routes && interface.routes.forEach((settings) => {
            interfaceCode += `\tpost-up route add -host ${settings.destination} dev ${interfaceName}\n`
        })

        interfaceCode += "\n"
    })

    host.dhcp && host.dhcp.settings.forEach((settings) => {
        dhcpCode += `shared-network ${settings.name} {\n`
        dhcpCode += `\tsubnet ${settings.subnet} netmask ${settings.netmask} {\n`
        dhcpCode += `\t\toption routers ${settings.gateway};\n`
        dhcpCode += `\t}\n`

        if (settings.poolRange) {
            dhcpCode += `\tpool {\n`
            dhcpCode += `\t\trange ${settings.poolRange}\n`
            dhcpCode += `\t}\n`
        }
        dhcpCode += `}\n\n`
    })

    host.dhcp && host.dhcp.staticAddresses && host.dhcp.staticAddresses.forEach((staticAddress) => {
        dhcpCode += `host ${staticAddress.serverName} {\n`
        dhcpCode += `\thardware ethernet ${staticAddress.macAddress};\n`
        dhcpCode += `\tfixed-address ${staticAddress.address};\n`
        dhcpCode += `}\n\n`
    })

    interfaceCode = interfaceCode.replace(/\t/g, "    ")
    dhcpCode = dhcpCode.replace(/\t/g, "    ")

    writeFileSync(join(outFolderPath, `${hostName}.sh`), `
echo "

${interfaceCode}
" >> /etc/network/interfaces

${dhcpCode !== "" ? `
# apt install isc-dhcp-server

sed -i "s/INTERFACES=\\"\\"/INTERFACES=\\"${host.dhcp.interfaces}\\"/g" /etc/default/isc-dhcp-server

${natting ? `
sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
` : ""}

echo "

authoritative;
${dhcpCode}
" >> /etc/dhcp/dhcpd.conf

service isc-dhcp-server start
systemctl enable isc-dhcp-server
` : ""}
`)
})

