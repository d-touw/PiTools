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
apt-get install -y build-essential

touch /etc/network/interfaces/eth01
touch /etc/network/interfaces/eth02


cat > /etc/network/interfaces/eth01 <<'EOL'
auto eth0:1
iface eth0:1 inet static
        address 192.168.1.2
        netmask 255.255.255.0
EOL

cat > /etc/network/interfaces/eth01 <<'EOL'
auto eth0:2
iface eth0:2 inet static
        address 192.168.2.90
        netmask 255.255.255.0
EOL

./APSetup.sh


else
    echo 'Please run this as Root/Sudo'
fi
