# VPC Peering
resource "aws_vpc_peering_connection" "prd_dev_peer" {
  vpc_id        = aws_vpc.prd_vpc.id
  peer_vpc_id   = aws_vpc.dev_vpc.id
  auto_accept   = true

  tags = {
    Name = "prd-dev-peering"
  }
}

# PRD VPC Route Table Update
resource "aws_route" "prd_to_dev_route" {
  route_table_id         = aws_route_table.prd_pub_rt.id # PRD VPC의 라우트 테이블 ID
  destination_cidr_block = aws_vpc.dev_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.prd_dev_peer.id
}

# DEV VPC Route Table Update
resource "aws_route" "dev_to_prd_route" {
  route_table_id         = aws_route_table.dev_pub_rt.id # DEV VPC의 라우트 테이블 ID
  destination_cidr_block = aws_vpc.prd_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.prd_dev_peer.id
}