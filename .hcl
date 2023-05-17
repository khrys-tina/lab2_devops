# Встановлення постачальника AWS
provider "aws" {
  region = var.aws_region
}

# Створення VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Створення підмереж
resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
}

# Створення групи безпеки
resource "aws_security_group" "my_security_group" {
  vpc_id = aws_vpc.my_vpc.id

  # Налаштування правил файрволу
  # Наприклад, дозволити доступ до порту 22 для SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Налаштування правил доступу SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Відкриття доступу до портів Prometheus, Node Exporter та Cadvizor Exporter
  ingress {
    from_port   = 9090  # Prometheus
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9100  # Node Exporter
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080  # Cadvizor Exporter
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Створення EC2-інстансів
resource "aws_instance" "instance1" {
  ami           = var.aws_ami
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet1.id
  key_name      = var.aws_key_name

  user_data = <<-EOF
    #!/bin/bash

    # Встановлення Docker
    sudo apt-get update
    sudo apt-get install -y docker.io

    # Запуск контейнера Prometheus
    sudo docker run -d --name prometheus -p 9090:9090 prom/prometheus

    # Встановлення Node Exporter
    sudo docker run -d --name node-exporter -p 9100:9100 prom/node-exporter

    # Встановлення Cadvizor Exporter
    sudo docker run -d --name cadvizor-exporter -p 8080:8080 google/cadvisor
  EOF
}
