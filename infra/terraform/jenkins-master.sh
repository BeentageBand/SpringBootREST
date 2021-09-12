local private_key
private_key="$1"
shift

local jenkins_node_dns
jenkins_node_dns=($@)


# Jenkins Installation
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
echo 'deb https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update
sudo apt install -y maven openjdk-8-jre openjdk-11-jdk
sudo apt install -y jenkins
sudo service jenkins start
sudo service jenkins status

# Ansible Installation
sudo apt install ansible -y

echo "${private_key}" > ~/.ssh/jenkins.pem
chmod 600 ~/.ssh/jenkins.pem
sudo sed -i '71s/.*/host_key_checking = False/' /etc/ansible/ansible.cfg

echo "setting up ${jenkins_node_dns[@]}"
IFS='\n' cat << EOF >> hosts
[jenkins]
${jenkins_node_dns[@]}
EOF
