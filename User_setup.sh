#!/bin/bash

# Prompt for the username
read -p "Enter the username of the new user: " username

# Create the new user
adduser $username

# Prompt for the user password
passwd $username

# Add the new user to the SSH user list
usermod -aG ssh $username

# Generate SSH keys for 'root' and the new user
ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ""
ssh-keygen -t rsa -f /home/$username/.ssh/id_rsa -N ""

# Set correct permissions for SSH keys
chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa.pub

chmod 700 /home/$username/.ssh
chmod 600 /home/$username/.ssh/id_rsa
chmod 600 /home/$username/.ssh/id_rsa.pub

# Copy keys to SSH directories
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
cp /home/$username/.ssh/id_rsa.pub /home/$username/.ssh/authorized_keys

# Set ownership for the new user's .ssh folder and authorized_keys
chown -R $username:$username /home/$username/.ssh
chown $username:$username /home/$username/.ssh/authorized_keys

# Disable password authentication in the SSH config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# Restart the SSH service to apply changes
service ssh restart
