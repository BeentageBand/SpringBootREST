# Jenkins Installation
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
echo 'deb https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update
sudo apt install -y maven openjdk-8-jre openjdk-11-jdk
sudo apt install -y jenkins
sudo service jenkins start
sudo service jenkins status

# Ansible Installation
sudo apt update -y
sudo apt install ansible -y

echo "${tls_private_key.private-key.private_key_pem}" > ~/.ssh/jenkins.pem
chmod 600 ~/.ssh/jenkins.pem
sudo sed -i '71s/.*/host_key_checking = False/' /etc/ansible/ansible.cfg

cat << EOF >> hosts
[jenkins]
${aws_instance.jenkins.*.public_dns[1]}
${aws_instance.jenkins.*.public_dns[2]}
EOF
