#!/bin/bash

# Set hostname
hostname="autosrv"
sudo hostnamectl set-hostname "$hostname"
echo **SUCCESS**

# Set static IP address
sudo bash -c 'echo "auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.16.21/24
    gateway 192.168.16.1
    dns-nameservers 192.168.16.1
    dns-search home.arpa localdomain" > /etc/network/interfaces'
echo **SUCCESS**

# Install required software
sudo apt update
sudo apt-get install -y openssh-server apache2 squid ufw
echo **SUCCESS**

# Configure SSH server
sudo sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
systemctl restart sshd
echo **SUCCESS**

# Configure Apache2 web server
ufw allow in "Apache Full"
systemctl enable apache2
echo **SUCCESS**

# Configure Squid web proxy
sudo bash -c "sed -i 's/http_access deny all/http_access allow all/' /etc/squid/squid.conf"
echo **SUCCESS**

# Enable Squid service
sudo systemctl enable squid
echo **SUCCESS**

# Configure firewall
ufw allow ssh
ufw allow https
ufw allow http
ufw allow 3128
ufw enable
echo **SUCCESS**

# Create user accounts and set up ssh keys
sudo mkdir /home/dennis
sudo useradd -m -d /home/dennis -s /bin/bash dennis
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
echo **SUCCESS**

# Set up ssh keys for all users
for user in dennis aubrey captain snibbles brownie scooter sandy perrier cindy tiger yoda; do
    sudo mkdir /home/$user/.ssh
    sudo ssh-keygen -t rsa -f /home/$user/.ssh/id_rsa -N ''
    sudo ssh-keygen -t ed25519 -f /home/$user/.ssh/id_ed25519 -N ''
    sudo cat /home/$user/.ssh/*.pub > /home/$user/.ssh/authorized_keys
    sudo chmod 700 /home/$user/.ssh
    sudo chmod 600 /home/$user/.ssh/*
    sudo chown -R $user:$user /home/$user/.ssh
    sudo chmod 644 "/home/dennis/.ssh/authorized_keys

done
echo **SUCCESS**
