# PRD VPC 생성
resource "aws_vpc" "prd_vpc" {
  cidr_block           = "10.250.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "prd_vpc"
  }
}

# DEV VPC 생성
resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.230.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "dev_vpc"
  }
}

# PRD IGW 생성
resource "aws_internet_gateway" "prd_igw" {
  vpc_id = resource.aws_vpc.prd_vpc.id
  tags = {
    Name = "prd_igw"
  }
}

# DEV IGW 생성
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = resource.aws_vpc.dev_vpc.id
  tags = {
    Name = "dev_igw"
  }
}

# PRD-EIP 생성
resource "aws_eip" "prd_bastion_eip" {
  instance = aws_instance.prd_bastion.id
  vpc      = true

  tags = {
    Name = "prd_bastion_eip"
  }
}

resource "aws_eip" "prd_nat_eip" {
  vpc = true

  tags = {
    Name = "prd_nat_eip"
  }
}

# DEV-EIP 생성
resource "aws_eip" "dev_bastion_eip" {
  instance = aws_instance.dev_bastion.id
  vpc      = true

  tags = {
    Name = "dev_bastion_eip"
  }
}

resource "aws_eip" "dev_nat_eip" {
  vpc = true

  tags = {
    Name = "dev_nat_eip"
  }
}

# PRD NAT 생성
resource "aws_nat_gateway" "prd_nat" {
  allocation_id = aws_eip.prd_nat_eip.id
  subnet_id     = aws_subnet.prd_pub_sub_c.id

  tags = {
    Name = "prd_nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.prd_igw]
}

# DEV NAT 생성
resource "aws_nat_gateway" "dev_nat" {
  allocation_id = aws_eip.dev_nat_eip.id
  subnet_id     = aws_subnet.dev_pub_sub_c.id

  tags = {
    Name = "dev_nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.dev_igw]
}


# prd Public rtb
resource "aws_route_table" "prd_pub_rt" {
  vpc_id = aws_vpc.prd_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prd_igw.id
  }

  tags = {
    Name = "prd_pub_rt"
  }
}

# dev Public rtb
resource "aws_route_table" "dev_pub_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "dev_pub_rt"
  }
}

# prd Private rtb
resource "aws_route_table" "prd_pri_rt_a" {
  vpc_id = aws_vpc.prd_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.prd_nat.id
  }

  tags = {
    Name = " prd_pri_rt_2a"
  }
  depends_on = [aws_nat_gateway.prd_nat]
}

resource "aws_route_table" "prd_pri_rt_c" {
  vpc_id = aws_vpc.prd_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.prd_nat.id
  }

  tags = {
    Name = " prd_pri_rt_2c"
  }
  depends_on = [aws_nat_gateway.prd_nat]
}

# dev Private rtb
resource "aws_route_table" "dev_pri_rt_a" {
  vpc_id = aws_vpc.dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dev_nat.id
  }

  tags = {
    Name = " dev_pri_rt_2a"
  }
  depends_on = [aws_nat_gateway.dev_nat]
}

resource "aws_route_table" "dev_pri_rt_c" {
  vpc_id = aws_vpc.dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dev_nat.id
  }

  tags = {
    Name = " dev_pri_rt_2c"
  }
  depends_on = [aws_nat_gateway.dev_nat]
}

# prd rtb association
resource "aws_route_table_association" "prd_pub_a" {
  subnet_id      = aws_subnet.prd_pub_sub_a.id
  route_table_id = aws_route_table.prd_pub_rt.id
}

resource "aws_route_table_association" "prd_pub_c" {
  subnet_id      = aws_subnet.prd_pub_sub_c.id
  route_table_id = aws_route_table.prd_pub_rt.id
}

resource "aws_route_table_association" "prd_mgnt_sub_a" {
  subnet_id      = aws_subnet.prd_mgnt_sub_a.id
  route_table_id = aws_route_table.prd_pri_rt_a.id
}

resource "aws_route_table_association" "prd_mgnt_sub_c" {
  subnet_id      = aws_subnet.prd_mgnt_sub_c.id
  route_table_id = aws_route_table.prd_pri_rt_c.id
}

resource "aws_route_table_association" "prd_node_sub_a" {
  subnet_id      = aws_subnet.prd_node_sub_a.id
  route_table_id = aws_route_table.prd_pri_rt_a.id
}

resource "aws_route_table_association" "prd_node_sub_c" {
  subnet_id      = aws_subnet.prd_node_sub_c.id
  route_table_id = aws_route_table.prd_pri_rt_c.id
}

resource "aws_route_table_association" "prd_db_pri_a" {
  subnet_id      = aws_subnet.prd_db_sub_a.id
  route_table_id = aws_route_table.prd_pri_rt_a.id
}

resource "aws_route_table_association" "prd_db_pri_c" {
  subnet_id      = aws_subnet.prd_db_sub_c.id
  route_table_id = aws_route_table.prd_pri_rt_c.id
}

# dev rtb association
resource "aws_route_table_association" "dev_pub_a" {
  subnet_id      = aws_subnet.dev_pub_sub_a.id
  route_table_id = aws_route_table.dev_pub_rt.id
}

resource "aws_route_table_association" "dev_pub_c" {
  subnet_id      = aws_subnet.dev_pub_sub_c.id
  route_table_id = aws_route_table.dev_pub_rt.id
}

resource "aws_route_table_association" "dev_mgnt_sub_a" {
  subnet_id      = aws_subnet.dev_mgnt_sub_a.id
  route_table_id = aws_route_table.dev_pri_rt_a.id
}

resource "aws_route_table_association" "dev_mgnt_sub_c" {
  subnet_id      = aws_subnet.dev_mgnt_sub_c.id
  route_table_id = aws_route_table.dev_pri_rt_c.id
}

resource "aws_route_table_association" "dev_node_sub_a" {
  subnet_id      = aws_subnet.dev_node_sub_a.id
  route_table_id = aws_route_table.dev_pri_rt_a.id
}

resource "aws_route_table_association" "dev_node_sub_c" {
  subnet_id      = aws_subnet.dev_node_sub_c.id
  route_table_id = aws_route_table.dev_pri_rt_c.id
}

resource "aws_route_table_association" "dev_db_pri_a" {
  subnet_id      = aws_subnet.dev_db_sub_a.id
  route_table_id = aws_route_table.dev_pri_rt_a.id
}

resource "aws_route_table_association" "dev_db_pri_c" {
  subnet_id      = aws_subnet.dev_db_sub_c.id
  route_table_id = aws_route_table.dev_pri_rt_c.id
}