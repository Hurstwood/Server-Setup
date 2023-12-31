#!/bin/bash


HEADING_BLUE='\033[0;34m'  # ANSI escape code for blue text
NC='\033[0m'  # ANSI escape code to reset to default text color

echo -e "${HEADING_BLUE}-- User creation${NC}"
read -p "Enter the username of the new user: " username
adduser --home "/home/$username"

echo -e "${HEADING_BLUE}-- Adding user to groups${NC}"
echo "ssh"
if ! getent group ssh > /dev/null; then
  groupadd ssh
fi
usermod -aG ssh $username

echo -e "${HEADING_BLUE}-- Generating SSH keys for root and new user${NC}"
# Check the directories exist
root_path="/root/.ssh"
user_path="/home/$username/.ssh"
mkdir -p "$root_path" "$user_path"

# Generate keys
ssh-keygen -t rsa -f $root_path/id_rsa -N ""
ssh-keygen -t rsa -f $user_path/id_rsa -N ""

# Set the correct permissions
chmod 700 "$root_path"
chmod 600 "$root_path/id_rsa"
chmod 600 "$root_path/id_rsa.pub"

chmod 700 "$user_path"
chmod 600 "$user_path/id_rsa"
chmod 600 "$user_path/id_rsa.pub"

# Copy keys to SSH directories
cp "$root_path/id_rsa.pub" "$root_path/authorized_keys"
cp "$user_path/id_rsa.pub" "$user_path/authorized_keys"

# Set ownership for the new user's .ssh folder and authorized_keys
chown -R "$username:$username" "$user_path"

# Disable password authentication in the SSH config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

# Restart the SSH service to apply changes
service ssh restart
