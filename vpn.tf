# PRD용 vpn 보안 그룹 생성
resource "aws_security_group" "prd_vpn_sg" {
  name        = "prd-vpn-sg"
  description = "Security group for PRD VPN"
  vpc_id      = aws_vpc.prd_vpc.id

  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["10.250.0.0/16"]  # PRD 대역
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["10.250.0.0/16"]  # PRD 대역
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "udp"
    cidr_blocks = ["10.250.0.0/16"]  # PRD 대역
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # 모든 트래픽 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prd-vpn-sg"
  }
}

# 가상 프라이빗 게이트웨이 (서울)
resource "aws_vpn_gateway" "prd_vpn_gw" {
  vpc_id = aws_vpc.prd_vpc.id

  tags = {
    Name = "prd-vpn-gw"
  }
}

# Ubuntu 22.04 LTS AMI 검색 (자동으로 최신 AMI 가져오기)
data "aws_ami" "ubuntu_22_04" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical (Ubuntu) 소유자 ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# EC2 인스턴스 생성 (VPN을 위한 고객 게이트웨이 역할)
resource "aws_instance" "vpn_gateway_instance" {
  ami           = data.aws_ami.ubuntu_22_04.id  # 검색된 AMI ID 사용
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.prd_vpn_sg.id]
  subnet_id     = aws_subnet.prd_pub_sub_a.id
  private_ip             = "10.250.1.243"

  # 퍼블릭 IP 할당
  associate_public_ip_address = true

  # 키페어
  key_name = "awesomekey"

  tags = {
    Name = "vpn-gateway-instance"
  }
}

# Elastic IP 생성
resource "aws_eip" "vpn_gateway_eip" {
  vpc = true
  instance = aws_instance.vpn_gateway_instance.id  # EC2 인스턴스에 Elastic IP 연결

  tags = {
    Name = "prd-vpn-eip"
  }
}

# 고객 게이트웨이에 퍼블릭 IP 사용 (Elastic IP)
resource "aws_customer_gateway" "prd_vpn_cgw" {
  bgp_asn    = 65000
  ip_address = aws_eip.vpn_gateway_eip.public_ip  # Elastic IP를 사용
  type       = "ipsec.1"

  tags = {
    Name = "prd-vpn-cgw"
  }
}


# VPN 연결 (서울 → 버지니아)
resource "aws_vpn_connection" "prd_to_virginia_vpn" {
  customer_gateway_id = aws_customer_gateway.prd_vpn_cgw.id
  vpn_gateway_id      = aws_vpn_gateway.prd_vpn_gw.id
  type                = "ipsec.1"

  # 정적 라우팅 사용
  static_routes_only  = true

  tags = {
    Name = "prd-vpn-connection"
  }
}

# VPN 연결 라우트 (정적 라우팅 사용)
resource "aws_vpn_connection_route" "prd_vpn_route" {
  vpn_connection_id = aws_vpn_connection.prd_to_virginia_vpn.id
  destination_cidr_block = "10.240.0.0/16"
}

