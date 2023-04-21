# vpc
# subnet public
# security group
# 2 ec2 instance


resource "aws_vpc" "vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "demo-public-subnet"
  }
}

resource "aws_security_group" "sg" {
  name        = "demo-sg"
  description = "demo-sg"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # kubernetes api server
    description = "Kubernetes API Server"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # kubernetes api server
    description = "Kubernetes API Server"
    from_port   = 10250
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 2379 and 2380
  ingress {
    description = "etcd"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    description = "Flannel"
    from_port   = 8472
    to_port     = 8472
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # node port
    description = "Node Port"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "demo-sg"
  }

}

resource "tls_private_key" "mykey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  filename        = "private_key.pem"
  content         = tls_private_key.mykey.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "demo-key" {
  key_name   = "demo-key"
  public_key = tls_private_key.mykey.public_key_openssh
}

data "aws_ami" "canonical" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "master" {
  ami                         = data.aws_ami.canonical.id
  instance_type               = var.intance_size
  key_name                    = aws_key_pair.demo-key.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]

  provisioner "local-exec" {
    command = "until nc -z -v -w30 ${self.public_ip} 22; do echo Waiting for SSH connection...; sleep 5; done; sleep 30"
  }

  tags = {
    Name = "demo-master"
  }
}


resource "aws_instance" "slave" {
  ami                         = data.aws_ami.canonical.id
  instance_type               = var.intance_size
  key_name                    = aws_key_pair.demo-key.key_name
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.sg.id]

  provisioner "local-exec" {
    command = "until nc -z -v -w30 ${self.public_ip} 22; do echo Waiting for SSH connection...; sleep 5; done; sleep 30"
  }


  tags = {
    Name = "demo-slave"
  }
}

resource "local_file" "ansible_inventory" {
  content = <<EOF
[master]
${aws_instance.master.public_ip}

[worker]
${aws_instance.slave.public_ip}
EOF

  filename = "ansible/ansible-inventory.ini"

  file_permission = "0644"
}




resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "demo-gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "demo-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "null_resource" "k8s" {
  depends_on = [
    aws_instance.master,
    aws_instance.slave,
  ]

  provisioner "local-exec" {
    command = "ansible-playbook -i ${local_file.ansible_inventory.filename} -u ubuntu --private-key ${local_file.private_key.filename} ansible/k8s.yml --ssh-common-args='-o StrictHostKeyChecking=no'"
  }
}
