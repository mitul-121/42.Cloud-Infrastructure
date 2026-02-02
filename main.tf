resource "aws_vpc" "devops_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "DevOpsVPC"
  }
}

resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.devops_vpc.id
    cidr_block              = var.public_subnet_cidr
    availability_zone       = var.availability_zone
    map_public_ip_on_launch = true
    
    tags = {
        Name = "DevOpsPublicSubnet"
    }  
}

resource "aws_subnet" "private" {
    vpc_id            = aws_vpc.devops_vpc.id
    cidr_block        = var.private_subnet_cidr
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true

    tags = {
        Name = "DevOpsPrivateSubnet"
    }  
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.devops_vpc.id
    
    tags = {
        Name = "DevOpsInternetGateway"
    }  
}


resource "aws_eip" "aws_elastic_ip" {
    domain = "vpc"
    tags = {
        Name = "DevOpsElasticIP"
    }  
  
}

resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.aws_elastic_ip.id
    subnet_id     = aws_subnet.public.id

    tags = {
        Name = "DevOpsNATGateway"
    }
  
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.devops_vpc.id
    route  { 
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }

    tags = {
        Name = "DevOpsPublicRouteTable"
    }  
  
}

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.devops_vpc.id
    route{
        cidr_block = "10.2.0.0/24"
        nat_gateway_id = aws_nat_gateway.nat_gateway.id
    }

    tags = {
        Name = "DevOpsPrivateRouteTable"
    }
  
}
resource "aws_route_table_association" "public_association" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public_route_table.id
}