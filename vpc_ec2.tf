resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-2a"  
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-2b"  
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}








resource "aws_security_group" "ec2_security_group" {
  name        = "ec2_security_group"
  description = "EC2 Security Group"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_key_pair" "terra-key" {
  key_name   = "terra-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCp7fmm3xRhDDRUqXmcrg1Yhl6TOOBGK57JO2+/1twHv7kRRb7t+ofyi0Vvh+SEFcmLkhgTmSJZ0WPSp9A16MRbNh+0tzoTjKK3AsC6NGvMtqCWQuanoN4yFxg/de7de5UMlflk9HUPK0zOugtJy4gmkrEHw64C92MUQ7MYMxnqUhgGhdWEw/zUuZ5mr1TqdBQZSH+xEiVQRtl9xJMUShNwz148Kpn+Zmi/h0rbhgJymYXLzCDo6KGFHZazgjsY9PJzhAnHPdpPpHY3Ld7g1OiZrjWYZlirs8Wgj0Q5bbix/ikXLYN0iYkIP8bZtSUoczI9GSuF9kesz/vhzeMw+xVVDjd3GS3Z5P2ZRZUNq4cCDSalKb0wXtmFPBF2+5dEF0wzXQWV2nXHoJtNkYiPK4E3NwregwbqHtfkeIavCWE4Sn7ekplB99p2lU3OxmGpP6Pw8GFfsaeYBmXLi9zZuxKq7fzWjgE/hm1HwjPjnm44qvVozBogjkaptmfHCvGXN2M= root@ip-172-31-23-170"
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-00ffa321011c2611f"  # Replace with your desired AMI ID
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = "terra-key"  # Replace with your key pair name

  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              service nginx start
              EOF
