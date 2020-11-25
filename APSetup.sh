#Based on: 	Setting up a Raspberry Pi as access point
#Source: 	https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md
#Authors:	Dustin Touw

#This script is to configure a Raspberry Pi as access point.

#!/bin/bash

is_user_root()
# function verified to work on Bash version 4.4.18
# both as root and with sudo; and as a normal user
{
    ! (( ${EUID:-0} || $(id -u) ))
}

if is_user_root; then
    echo 'You are the almighty root!'

apt-get update
apt-get upgrade -y
apt install -y dnsmasq hostapd

systemctl stop dnsmasq
systemctl stop hostapd

cat >> /etc/dhcpcd.conf <<'EOL'
interface wlan0
static ip_address=192.168.66.254/24
nohook wpa_supplicant
EOL


service dhcpcd restart

mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig


cat >> /etc/dnsmasq.conf <<'EOL'
interface=wlan0      # Use the require wireless interface - usually wlan0
dhcp-range=192.168.66.10,192.168.66.254,255.255.255.0,24h
EOL

cat > /etc/hostapd/hostapd.conf  <<'EOL'
interface=wlan0
driver=nl80211
ssid=Error404
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=Welkom01
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOL

cat >> /etc/default/hostapd <<'EOL'
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOL

sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd

cat >> /etc/sysctl.conf <<'EOL'
net.ipv4.ip_forward=1
EOL

iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE

sh -c "iptables-save > /etc/iptables.ipv4.nat"


cat > /etc/rc.local <<'EOL'
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# Print the IP address
_IP=$(hostname -I) || true
if [ "$_IP" ]; then
  printf "My IP address is %s\n" "$_IP"
fi
iptables-restore < /etc/iptables.ipv4.nat
exit 0
EOL

else
    echo 'Please run this as Root/Sudo'
fi
