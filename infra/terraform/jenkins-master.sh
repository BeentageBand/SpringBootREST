# !/bin/bash
set -x
# Jenkins Installation
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
echo 'deb https://pkg.jenkins.io/debian-stable binary/' | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update -y
sudo apt install -y maven openjdk-8-jre openjdk-11-jdk
sudo apt install -y jenkins

sudo service jenkins start

# setup .ssh
sudo cp -r ~/.ssh /var/lib/jenkins/
sudo chown jenkins -R /var/lib/jenkins/.ssh

