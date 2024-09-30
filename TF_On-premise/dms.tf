# DMS 인스턴스를 위한 보안 그룹 (버지니아)
resource "aws_security_group" "onprem_dms_sg" {
  name        = "prd-dms-sg"
  description = "Security group for PRD DMS Replication Instance"
  vpc_id      = aws_vpc.onprem_vpc.id

  # Ingress: DMS 복제 인스턴스가 데이터베이스와 통신할 수 있도록 허용 (MySQL 예시)
  ingress {
    from_port   = 3306  # MySQL 포트 (다른 DB 엔진을 사용하면 해당 포트를 설정)
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.240.0.0/16"]  # ONPREMISE 대역
  }

  # Ingress: DMS 인스턴스와 VPN 간 통신을 허용 (필요 시 다른 포트 추가 가능)
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["10.240.0.0/16"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["10.240.0.0/16"]
  }

  # Egress: 외부로 나가는 모든 트래픽을 허용 (필요시 제한 가능)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "onprem-dms-sg"
  }
}


# DMS VPC IAM 역할 생성
resource "aws_iam_role" "dms_vpc_role" {
  name = "dms-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "dms.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "dms_vpc_policy" {
  name        = "dms-vpc-policy"
  description = "IAM Policy for DMS VPC Role"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ec2:Describe*",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:AttachNetworkInterface"
        ],
        Resource = "*"
      }
    ]
  })
}


# DMS VPC IAM 기존 정책을 참조
resource "aws_iam_role_policy_attachment" "dms_vpc_role_policy_attachment" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = aws_iam_policy.dms_vpc_policy.arn
}


# DMS 복제 인스턴스 (버지니아)
resource "aws_dms_replication_instance" "onprem_dms_instance" {
  replication_instance_id     = "onprem-dms-instance"
  replication_instance_class  = "dms.t2.micro"
  allocated_storage           = 100
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.onprem_dms_sg.id, aws_security_group.onprem_vpn_sg.id]
  availability_zone           = "us-east-1a"
  replication_subnet_group_id = aws_dms_replication_subnet_group.onprem_dms_subnet_group.id

  depends_on = [aws_iam_role_policy_attachment.dms_vpc_role_policy_attachment]  # 의존성 추가

  tags = {
    Name = "onprem-dms-instance"
  }
}


# DMS 서브넷 그룹 생성
resource "aws_dms_replication_subnet_group" "onprem_dms_subnet_group" {
  replication_subnet_group_id = "onprem-dms-subnet-group"
  replication_subnet_group_description = "Subnet group for onprem DMS replication"
  subnet_ids                  = [aws_subnet.onprem_public.id, aws_subnet.onprem_public_1b.id]

  tags = {
    Name = "onprem-dms-subnet-group"
  }
}