provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "ldap_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ldap-vpc"
  }
}

# Subred Pública
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.ldap_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone

  tags = {
    Name = "public-subnet"
  }
}

# Subred Privada
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.ldap_vpc.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone

  tags = {
    Name = "private-subnet"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ldap_vpc.id

  tags = {
    Name = "ldap-igw"
  }
}

# Tabla de rutas pública
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.ldap_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}



# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = var.eip_nat_allocation_id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "nat-gateway"
  }
}


# Tabla de rutas privada
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.ldap_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-rt"
  }
}

# Asociación de tabla de rutas pública con la subred pública
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Asociación de tabla de rutas privada con la subred privada
resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}


# Grupo de Seguridad para la Instancia Web con HTTP, SSH y HTTPS
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP, SSH, HTTPS"
  vpc_id      = aws_vpc.ldap_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Grupo de Seguridad para la Instancia LDAP
resource "aws_security_group" "ldap_sg" {
  name        = "ldap-sg"
  description = "Allow LDAP traffic from web server and SSH from admin"
  vpc_id      = aws_vpc.ldap_vpc.id

  # LDAP port (389) - only from web server SG
  ingress {
    from_port       = 389
    to_port         = 389
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # SSH (only from trusted IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # Egress: all outbound allowed
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ldap-sg"
  }
}


resource "aws_instance" "web_server" {
  ami                         = "ami-0c2b8ca1dad447f8a"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = false  # Importante

  user_data = file("web_user_data.sh")

  tags = {
    Name = "Servidor-Web"
  }
}



# Instancia LDAP (privada)
resource "aws_instance" "ldap_server" {
  ami                         = "ami-0c2b8ca1dad447f8a" # cambia si tienes una AMI LDAP específica
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private_subnet.id
  key_name                    = var.key_name2
  vpc_security_group_ids      = [aws_security_group.ldap_sg.id]
  associate_public_ip_address = false

  user_data = file("ldap_user_data.sh")


  tags = {
    Name = "LDAP-Servidor"
  }
}


#Recurso de asociacion de Elastic IP para la instancia web
resource "aws_eip_association" "web_eip_assoc" {
  allocation_id = var.eip_web_allocation_id
  instance_id   = aws_instance.web_server.id
}



