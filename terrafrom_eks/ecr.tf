resource "aws_ecr_repository" "nginx-index" {
  name                 = "nginx-index"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "nginx-index"
  }
}

resource "aws_ecr_repository" "nginx-index-dms" {
  name                 = "nginx-index-dms"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "nginx-index-dms"
  }
}

resource "aws_ecr_repository" "nginx-login" {
  name                 = "nginx-login"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "nginx-login"
  }
}

resource "aws_ecr_repository" "nginx-login-dms" {
  name                 = "nginx-login-dms"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "nginx-login-dms"
  }
}

resource "aws_ecr_repository" "nginx-signup" {
  name                 = "nginx-signup"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "nginx-signup"
  }
}

resource "aws_ecr_repository" "nginx-signup-dms" {
  name                 = "nginx-signup-dms"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "nginx-signup-dms"
  }
}

resource "aws_ecr_repository" "nginx-admin" {
  name                 = "nginx-admin"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "nginx-admin"
  }
}

resource "aws_ecr_repository" "tomcat-index" {
  name                 = "tomcat-index"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "tomcat-index"
  }
}

resource "aws_ecr_repository" "tomcat-index-dms" {
  name                 = "tomcat-index-dms"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "tomcat-index-dms"
  }
}

resource "aws_ecr_repository" "tomcat-login" {
  name                 = "tomcat-login"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "tomcat-login"
  }
}

resource "aws_ecr_repository" "tomcat-login-dms" {
  name                 = "tomcat-login-dms"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "tomcat-login-dms"
  }
}

resource "aws_ecr_repository" "tomcat-signup" {
  name                 = "tomcat-signup"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "tomcat-signup"
  }
}

resource "aws_ecr_repository" "tomcat-signup-dms" {
  name                 = "tomcat-signup-dms"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "tomcat-signup-dms"
  }
}

resource "aws_ecr_repository" "tomcat-admin" {
  name                 = "tomcat-admin"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
  tags = {
    Name = "tomcat-admin"
  }
}