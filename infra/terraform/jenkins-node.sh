# !/bin/bash
set -x
# Jenkins Node Installation
sudo apt update -y
sudo apt install -y ansible maven openjdk-8-jre openjdk-11-jdk
sudo sed -i '71s;.*;host_key_checking = False;' /etc/ansible/ansible.cfg
sudo sed -i '136s;.*;private_key= ~/.ssh/jenkins.pem;' /etc/ansible/ansible.cfg


