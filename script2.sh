#!/bin/bash

# Set hostname
hostnamectl set-hostname autosrv

# Set network configuration
cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 192.168.16.21
netmask 255.255.255.0
gateway 192.168.16.1
dns-nameservers 192.168.16.1
dns-search home.arpa localdomain
EOF

# Install required software
apt-get update
apt-get install -y openssh-server apache2 squid ufw

# Configure SSH server
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart ssh

# Configure Apache2
ufw allow 'Apache Full'
systemctl enable apache2
systemctl restart apache2

# Configure Squid
cat <<EOF > /etc/squid/squid.conf
http_port 3128
acl localnet src 192.168.16.0/24
http_access allow localnet
EOF
systemctl enable squid
systemctl restart squid

# Configure Firewall
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 3128
ufw enable

# Create user accounts and set up ssh keys
sudo mkdir /home/dennis
sudo useradd -m -d /home/dennis -s /bin/bash dennis
sudo usermod -aG sudo dennis
sudo mkdir /home/aubrey
sudo useradd -m -d /home/aubrey -s /bin/bash aubrey
sudo mkdir /home/captain
sudo useradd -m -d /home/captain -s /bin/bash captain
sudo mkdir /home/snibbles
sudo useradd -m -d /home/snibbles -s /bin/bash snibbles
sudo mkdir /home/brownie
sudo useradd -m -d /home/brownie -s /bin/bash brownie
sudo mkdir /home/scooter
sudo useradd -m -d /home/scooter -s /bin/bash scooter
sudo mkdir /home/sandy
sudo useradd -m -d /home/sandy -s /bin/bash sandy
sudo mkdir /home/perrier
sudo useradd -m -d /home/perrier -s /bin/bash perrier
sudo mkdir /home/cindy
sudo useradd -m -d /home/cindy -s /bin/bash cindy
sudo mkdir /home/tiger
sudo useradd -m -d /home/tiger -s /bin/bash tiger
sudo mkdir /home/yoda
sudo useradd -m -d /home/yoda -s /bin/bash yoda

# Set up ssh keys for all users
for user in dennis aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda; do
    sudo mkdir /home/$user/.ssh
    sudo ssh-keygen -t rsa -f /home/$user/.ssh/id_rsa -N ''
    sudo ssh-keygen -t ed25519 -f /home/$user/.ssh/id_ed25519 -N ''
    sudo cat /home/$user/.ssh/*.pub > /home/$user/.ssh/authorized_keys
    sudo chmod 700 /home/$user/.ssh
    sudo chmod 600 /home/$user/.ssh/*
    sudo chown -R $user:$user /home/$user/.ssh
done

# Set up sudo access for dennis
echo 'dennis ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dennis
chmod 440 /etc/sudoers.d/dennis
