#!/bin/bash


HEADING_BLUE='\033[0;34m'  # ANSI escape code for blue text
NC='\033[0m'  # ANSI escape code to reset to default text color

echo -e "${HEADING_BLUE}-- User creation${NC}"
read -p "Enter the username of the new user: " username
adduser $username

echo -e "${HEADING_BLUE}-- User password change${NC}"
passwd $username

echo -e "${HEADING_BLUE}-- Adding user to groups${NC}"
echo "ssh"
usermod -aG ssh $username

echo -e "${HEADING_BLUE}-- Generating SSH keys for root and new user${NC}"
# Check the directories exist
root_path="/root/.ssh/"
if [ ! -d "$root_path" ]; then
  mkdir "$root_path"
fi

user_path="/home/$username/.ssh"
if [ ! -d "$user_path" ]; then
  mkdir "$user_path"
fi

# Generate keys
ssh-keygen -t rsa -f $root_path/id_rsa -N ""
ssh-keygen -t rsa -f $user_path/.ssh/id_rsa -N ""

# Set the correct permissions
chmod 700 $root_path
chmod 600 $root_path/id_rsa
chmod 600 $root_path/id_rsa.pub

chmod 700 $user_path
chmod 600 $user_path/id_rsa
chmod 600 $user_path/id_rsa.pub

# Copy keys to SSH directories
cp $root_path/id_rsa.pub $root_path/authorized_keys
cp $user_path/id_rsa.pub $user_path/authorized_keys

# Set ownership for the new user's .ssh folder and authorized_keys
chown -R $username:$username $user_path
chown $username:$username $user_path/authorized_keys

# Disable password authentication in the SSH config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# Restart the SSH service to apply changes
service ssh restart
