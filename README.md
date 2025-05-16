# Secure WordPress Deployment on AWS (Terraform)

This is a real-world, secure-by-default setup for hosting WordPress sites in AWS using Terraform. I built this as a hands-on DevSecOps project to go from idea → working infrastructure → production-grade deployment.

---

## 🔒 What This Deploys

- **VPC** with public/private subnets across 2 AZs
- **NAT Gateway** for private subnet egress
- **EC2 (Amazon Linux 2)** instance in private subnet with WordPress pre-installed
- **RDS (MySQL)** in private subnet, locked down to EC2 only
- **ALB (Application Load Balancer)** for public traffic
- **ACM TLS Certificate** for HTTPS (auto-validated via DNS)
- **WAF** with AWS-managed rule sets (WordPress-specific and general)
- All infrastructure deployed with **Terraform**, no manual steps required

---

## 🚀 Usage

Make sure you have:
- Terraform installed
- AWS credentials configured
- A public domain name (for HTTPS)

Then:

```bash
git clone git@github.com:skeletor-eht/terraform-wordpress-aws.git
cd terraform-wordpress-aws

terraform init
terraform plan
terraform apply


## NOTES

WordPress auto-installs and configures wp-config.php on boot

The database is created automatically using a CREATE DATABASE IF NOT EXISTS line in user data

Admin credentials for MySQL are hardcoded for now — would use SSM or Secrets Manager in production

You can scale this architecture for multiple sites by refactoring into modules

📦 Still To Do...Coming Soon 

Add CloudFront for global CDN

Automate deploys with CI/CD

Swap NAT Gateway for NAT Instance (to reduce costs)

Package this into a reusable module


