# Key (ssh-keygen -m PEM -f awesomekey)
resource "aws_key_pair" "key" {
  key_name   = "awesomekey"
  public_key = file("awesomekey.pub")
}

# Public에 prd Bastion Instance 생성
resource "aws_instance" "prd_bastion" {
  ami                    = data.aws_ami.ubuntu_22_04_1.id
  instance_type          = "t2.micro"
  key_name               = "awesomekey"
  vpc_security_group_ids = [aws_security_group.prd_bastion_security.id]
  subnet_id              = aws_subnet.prd_pub_sub_c.id

  tags = {
    Name = "prd_bastion"
  }
}

# Public에 dev Bastion Instance 생성
resource "aws_instance" "dev_bastion" {
  ami                    = data.aws_ami.ubuntu_22_04_2.id
  instance_type          = "t2.micro"
  key_name               = "awesomekey"
  vpc_security_group_ids = [aws_security_group.dev_bastion_security.id]
  subnet_id              = aws_subnet.dev_pub_sub_c.id

  tags = {
    Name = "dev_bastion"
  }
}

# Public에 Jenkins Instance 생성
resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.ubuntu_22_04_1.id
  instance_type          = "t3.medium"
  key_name               = "awesomekey"
  vpc_security_group_ids = [aws_security_group.jenkins_security.id]
  subnet_id              = aws_subnet.prd_pub_sub_a.id

  tags = {
    Name = "jenkins"
  }
}

# Public에 prd-k8s-managed Server 생성
resource "aws_instance" "prd_k8s-managed-Server" {
  ami                    = data.aws_ami.ubuntu_22_04_1.id
  instance_type          = "t3.medium"
  key_name               = "awesomekey"
  vpc_security_group_ids = [aws_security_group.prd_bastion_security.id]
  subnet_id              = aws_subnet.prd_pub_sub_a.id

  tags = {
    Name = "prd_k8s_managed_Server"
  }
} 

# Public에 dev-k8s-managed Server 생성
resource "aws_instance" "dev_k8s-managed-Server" {
  ami                    = data.aws_ami.ubuntu_22_04_2.id
  instance_type          = "t3.medium"
  key_name               = "awesomekey"
  vpc_security_group_ids = [aws_security_group.dev_bastion_security.id]
  subnet_id              = aws_subnet.dev_pub_sub_a.id

  tags = {
    Name = "dev_k8s_managed_Server"
  }
}

# Public에 prd-efs-managed Server 생성
resource "aws_instance" "prd_efs_managed_Server" {
  ami                    = data.aws_ami.ubuntu_22_04_1.id
  instance_type          = "t3.medium"
  key_name               = "awesomekey"
  vpc_security_group_ids = [aws_security_group.prd_bastion_security.id]
  subnet_id              = aws_subnet.prd_pub_sub_a.id

  tags = {
    Name = "prd_efs_managed_Server"
  }
}

# Public에 ArgoCD Instance 생성
resource "aws_instance" "pub_argocd" {
  ami                    = data.aws_ami.ubuntu_22_04_1.id
  instance_type          = "t2.micro"
  key_name               = "awesomekey"
  vpc_security_group_ids = [aws_security_group.prd_bastion_security.id]
  subnet_id              = aws_subnet.prd_pub_sub_a.id

  tags = {
    Name = "prd_argocd"
  }
}

# AMI Data Source for Ubuntu 22.04
data "aws_ami" "ubuntu_22_04_1" {
  most_recent = true
  owners      = ["099720109477"] # Ubuntu 공식 AMI 계정 ID
  name_regex  = "^ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "ubuntu_22_04_2" {
  most_recent = true
  owners      = ["099720109477"] # Ubuntu 공식 AMI 계정 ID
  name_regex  = "^ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
