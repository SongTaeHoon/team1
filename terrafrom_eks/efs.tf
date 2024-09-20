# EFS 파일 시스템 생성
resource "aws_efs_file_system" "example" {
  creation_token = "my-efs"
  performance_mode = "generalPurpose"
}

# EFS 마운트 대상 생성
resource "aws_efs_mount_target" "example" {
  file_system_id = aws_efs_file_system.example.id
  subnet_id      = aws_subnet.prd_pub_sub_a.id# EFS를 마운트할 서브넷 ID
}

# 기존 EC2 인스턴스 참조
data "aws_instance" "efs_managed_server" {
  instance_id = aws_instance.prd_efs_managed_Server.id # 기존 EC2 인스턴스의 ID
}

# EFS 마운트를 위한 사용자 데이터 스크립트 (기존 인스턴스에 적용)
resource "null_resource" "efs_mount" {
  provisioner "remote-exec" {
    inline = [
      "yum install -y amazon-efs-utils",
      "mkdir -p /mnt/efs",
      "mount -t efs ${aws_efs_file_system.example.id}:/ /mnt/efs"
    ]

    connection {
      type        = "ssh"
      host        = data.aws_instance.efs_managed_server.public_ip# 인스턴스의 퍼블릭 IP
      user        = "ec2-user"# 사용자 이름 (예: Amazon Linux의 경우)
      private_key = file("C:/Users/keduit/Desktop/terrafrom_eks/awesomekey")# 개인 키 경로
    }
  }
}