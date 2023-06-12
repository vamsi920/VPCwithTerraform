# provider "aws" {
#   profile = "default"
#   region  = "us-east-1"
# }
# resource "aws_instance" "example" {
#   ami           = "ami-02396cdd13e9a1257"
#   instance_type = "t2.micro"
# }
# creating a vpc 
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
resource "aws_vpc" "dev"{
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "terraform-vpc"
  }
}
# creating a subnet
resource "aws_subnet" "sub1"{
  vpc_id = aws_vpc.dev.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "sub1"
  }
}

resource "aws_subnet" "sub2"{
  vpc_id = aws_vpc.dev.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "sub2"
  }
}

resource "aws_subnet" "sub3"{
  vpc_id = aws_vpc.dev.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
  tags = {
    Name = "sub3"
  }
}

resource "aws_subnet" "sub4"{
  vpc_id = aws_vpc.dev.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "us-east-1d"
  tags = {
    Name = "sub4"
  }
}


# creating a gateway

resource "aws_internet_gateway" "gw"{
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "gw"
  }
}

# creating a route table

resource "aws_route_table" "rt"{
  vpc_id = aws_vpc.dev.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "rt"
  }
}

# creating a route table association
resource "aws_route_table_association" "a"{
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "b"{
  subnet_id = aws_subnet.sub2.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "c"{
  subnet_id = aws_subnet.sub3.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "d"{
  subnet_id = aws_subnet.sub4.id
  route_table_id = aws_route_table.rt.id
}

# creating a vpg 
resource "aws_vpn_gateway" "vpg"{
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "vpg"
  }
}

# attaching vpg to vpc
resource "aws_vpn_gateway_attachment" "vpc_attach"{
  vpc_id = aws_vpc.dev.id
  vpn_gateway_id = aws_vpn_gateway.vpg.id
}

#creating a security group 
resource "aws_security_group" "sg"{
  name = "sg"
  description = "Allow http and ssh"
  vpc_id = aws_vpc.dev.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# create a direct connect gateway
resource "aws_dx_gateway" "dx"{
  name = "dx"
  amazon_side_asn = 64512
}

# associate direct connect gateway to vpc
resource "aws_dx_gateway_association" "dx_association"{
  dx_gateway_id = aws_dx_gateway.dx.id
  associated_gateway_id = aws_vpn_gateway.vpg.id
}

#creating 4 endpoint interfaces
resource "aws_vpc_endpoint" "ep1"{
  vpc_id = aws_vpc.dev.id
  service_name = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids = [aws_subnet.sub1.id]
  # private_dns_enabled = true
  tags = {
    Name = "ep1"
  }
}
resource "aws_vpc_endpoint" "ep2"{
  vpc_id = aws_vpc.dev.id
  service_name = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids = [aws_subnet.sub2.id]
  # private_dns_enabled = true
  tags = {
    Name = "ep2"
  }
}
resource "aws_vpc_endpoint" "ep3"{
  vpc_id = aws_vpc.dev.id
  service_name = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids = [aws_subnet.sub3.id]
  # private_dns_enabled = true
  tags = {
    Name = "ep3"
  }
}
resource "aws_vpc_endpoint" "ep4"{
  vpc_id = aws_vpc.dev.id
  service_name = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.sg.id]
  subnet_ids = [aws_subnet.sub4.id]
  # private_dns_enabled = true
  tags = {
    Name = "ep4"
  }
}

# create ec2 
resource "aws_instance" "web"{
  ami = "ami-02396cdd13e9a1257"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = {
    Name = "web"
  }
}
