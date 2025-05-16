# ✅ Lookup latest Amazon Linux 2 AMI dynamically
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ✅ IAM Role for EC2 to use SSM
resource "aws_iam_role" "ec2_ssm_role" {
  name = "wordpress-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# ✅ Attach SSM policy to EC2 role
resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ✅ Instance profile for EC2
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "wordpress-ec2-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

# ✅ EC2 Instance with WordPress and DB integration
resource "aws_instance" "wordpress" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_a.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_profile.name

  user_data = templatefile("${path.module}/wordpress_userdata.sh", {
    db_host = aws_db_instance.wordpress.endpoint
    db_user = "admin"
    db_pass = "Wordpress123!"
    db_name = "wordpress"
  })

  tags = {
    Name = "wordpress-instance"
  }

  depends_on = [
    aws_db_instance.wordpress,
    aws_iam_instance_profile.ec2_ssm_profile
  ]
}
