provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
  region                  = "us-east-1"
}

resource "tls_private_key" "private-key" {
  algorithm   = "RSA"
  rsa_bits    = 2048
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = tls_private_key.private-key.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "jenkins-sg" {
  name = "Jenkins-SG"
  description = "Student security group"

  tags = {
    Name = "Jenkins-SG"
    Environment = terraform.workspace
  }
}

resource "aws_security_group_rule" "create-sgr-ssh" {
  security_group_id = aws_security_group.jenkins-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 22
  protocol          = "tcp"
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "create-sgr-inbound" {
  security_group_id = aws_security_group.jenkins-sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "all"
  to_port           = 65535
  type              = "ingress"
}

resource "aws_security_group_rule" "create-sgr-outbound" {
  security_group_id = aws_security_group.jenkins-sg.id
  cidr_blocks         = ["0.0.0.0/0"]
  from_port         = 0
  protocol          = "all"
  to_port           = 65535
  type              = "egress"
}

resource "aws_instance" "jenkins" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = ["Jenkins-SG"]
  tags = {
    Name = "Jenkins${count.index}"
  }
}

resource "null_resource" "jenkins-master" {
    depends_on = [aws_instance.jenkins]
  
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.private-key.private_key_pem
      host        = aws_instance.jenkins.*.public_dns[0]
    }

    provisioner "file" {
        source      = "${path.cwd}/jenkins-master.sh"
        destination = "/tmp/jenkins-master.sh"
    }

    provisioner "remote-exec" {
        inline = [
          "chmod u+x /tmp/jenkins-node.sh",
          "/tmp/jenkins-master.sh '${join(" ",aws_instance.jenkins.*.public_dns)}'",
          "echo '${tls_private_key.private-key.private_key_pem}' > ~/.ssh/jenkins.pem && chmod 600 ~/.ssh/jenkins.pem",
          "echo '[jenkins]' > ~/hosts",
          "echo '${join("\n", aws_instance.jenkins.*.public_dns)}' > ~/hosts"
        ]
    }

    provisioner "local-exec" {
      command = "echo '${tls_private_key.private-key.private_key_pem}' > ~/.ssh/jenkins.pem && chmod 600 ~/.ssh/jenkins.pem "
    }
}

resource "null_resource" "jenkins-node" {
    depends_on = [aws_instance.jenkins]
  
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.private-key.private_key_pem
      host        = aws_instance.jenkins.*.public_dns[1]
    }

    provisioner "file" {
        source      = "${path.cwd}/jenkins-node.sh"
        destination = "/tmp/jenkins-node.sh"
    }

    provisioner "remote-exec" {
      inline =[
        "chmod u+x /tmp/jenkins-node.sh",
        "/tmp/jenkins-node.sh",
        "echo '${tls_private_key.private-key.private_key_pem}' > ~/.ssh/jenkins.pem && chmod 600 ~/.ssh/jenkins.pem"
      ] 
    }
}
