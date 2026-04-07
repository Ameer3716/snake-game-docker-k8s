# DevOps Assignment 3 — Terraform AWS Infrastructure

A complete Terraform implementation of AWS infrastructure including VPC, EC2, ASG, ALB, S3 state management, and reusable modules.

## 📋 Team Members

- **Member 1 (Roll No)**: Tasks 1, 2, 3
- **Member 2 (Roll No)**: Tasks 4, 5, 6

## 🛠️ Prerequisites

- Terraform >= 1.5
- AWS CLI >= 2.0
- Packer >= 1.9
- AWS credentials configured (`aws configure`)

## 📁 Project Structure

```
terraform/
├── main.tf                    # Tasks 1-5 resources (VPC, EC2, SGs, ASG, ALB)
├── variables.tf              # All variable definitions
├── outputs.tf                # Outputs for all tasks
├── terraform.tfvars          # Terraform variables (customize with your IP)
├── module_usage.tf           # Task 6: Module usage example
├── .gitignore               # Git ignore file
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── compute/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── packer/
    └── build.pkr.hcl        # Packer AMI builder
```

## 🚀 Quick Start

### Step 1: Set Up AWS Credentials

```bash
aws configure
# Enter:
# AWS Access Key ID: <your key>
# AWS Secret Access Key: <your secret>
# Default region: us-east-1
# Default output format: json
```

### Step 2: Get Your Public IP

```bash
curl ifconfig.me
```

### Step 3: Update terraform.tfvars

Replace `YOUR.PUBLIC.IP.HERE/32` with your actual IP:

```bash
cd terraform
# Edit terraform.tfvars and update my_ip variable
```

### Step 4: Initialize and Apply

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## 📝 Task Details

### Task 1: Custom VPC with Subneting and NAT Gateway
- ✅ VPC: `10.0.0.0/16`
- ✅ 2 Public Subnets: `10.0.1.0/24`, `10.0.2.0/24`
- ✅ 2 Private Subnets: `10.0.10.0/24`, `10.0.11.0/24`
- ✅ Internet Gateway for public access
- ✅ NAT Gateway for private-to-internet communication
- ✅ Separate route tables for public/private

**Get outputs:**
```bash
terraform output vpc_id
terraform output nat_gateway_id
```

---

### Task 2: Security Groups and EC2 Instances
- ✅ Web Security Group: SSH (from your IP), HTTP, HTTPS
- ✅ DB Security Group: MySQL from web SG only
- ✅ SSH Key Pair (auto-generated & saved as `devops-key.pem`)
- ✅ Public EC2: Web Server with Nginx pre-installed
- ✅ Private EC2: Database Server

**SSH into web server:**
```bash
chmod 400 devops-key.pem
ssh -i devops-key.pem ubuntu@$(terraform output -raw web_server_public_ip)
```

**Bastion Pattern - From web server to DB server:**
```bash
# Copy key to web server
scp -i devops-key.pem devops-key.pem ubuntu@<WEB_IP>:~/.ssh/

# SSH into web server, then to DB
ssh -i devops-key.pem ubuntu@<WEB_IP>
# Then from inside:
ssh -i ~/.ssh/devops-key.pem ubuntu@<DB_PRIVATE_IP>
```

---

### Task 3: S3 Bucket with Remote State
- ✅ S3 bucket with random suffix for uniqueness
- ✅ Versioning enabled
- ✅ Server-side encryption (AES256)
- ✅ Public access blocked
- ✅ DynamoDB table for state locking
- ✅ IAM role for EC2 → S3 access

**After running `terraform apply`, note the S3 bucket name:**
```bash
terraform output s3_bucket_name
```

**To migrate state to S3 backend:**
1. Run `terraform apply` first (creates the S3 bucket locally)
2. Copy the S3 bucket name from output
3. Uncomment the backend config in `main.tf` and replace `XXXX` with your bucket name
4. Run `terraform init -migrate-state` (type `yes` when prompted)

### Task 4: Auto Scaling Group with CloudWatch Alarms
- ✅ Launch Template with Nginx and stress-ng
- ✅ ASG: min=1, max=3, desired=1
- ✅ Scale-out: CPU >= 60% for 2 minutes → +1 instance
- ✅ Scale-in: CPU <= 20% for 2 minutes → -1 instance

**To test scaling:**
```bash
# Scale to 2 instances
terraform apply -var="desired_capacity=2" -auto-approve

# SSH into an instance and stress it
stress-ng --cpu 2 --timeout 300s &

# Watch in AWS Console: EC2 → Auto Scaling Groups → web-asg → Activity
```

---

### Task 5: Application Load Balancer
- ✅ ALB in public subnets
- ✅ Target group with health checks (path: `/`, healthy threshold: 2)
- ✅ ALB Listener on port 80
- ✅ ASG attached to target group

**Test load distribution:**
```bash
ALB=$(terraform output -raw alb_dns_name)
for i in {1..10}; do curl -s http://$ALB | grep "Instance ID"; done
# Shows different instance IDs = load balancing works
```

---

### Task 6: Terraform Modules + Packer

#### Modules
Three reusable modules:
- **vpc**: Custom VPC with 2 public + 2 private subnets, NAT Gateway
- **security**: Web & DB security groups
- **compute**: EC2 instance with Nginx

**Use modules:**
```bash
# module_usage.tf shows how to use them together
terraform apply -auto-approve
# Check outputs from module_* variables
```

#### Packer
Build a custom Ubuntu AMI with Nginx pre-installed:

```bash
cd terraform/packer
packer init .
packer build build.pkr.hcl
```

**Output:** Custom AMI ID (e.g., `ami-0abc123...`)

Update `terraform.tfvars` with the new AMI and reapply:
```bash
ami_id = "ami-0abc123..."
cd ..
terraform apply -auto-approve
```

---

## 🧪 Validation Commands

| Task | Command |
|------|---------|
| Initialize | `terraform init` |
| Plan | `terraform plan` |
| Apply | `terraform apply -auto-approve` |
| Show state | `terraform state list` |
| View outputs | `terraform output` |
| SSH to web | `ssh -i devops-key.pem ubuntu@$(terraform output -raw web_server_public_ip)` |
| ALB URL | `terraform output -raw alb_dns_name` |
| Destroy | `terraform destroy -auto-approve` |
| Validate vars | `terraform apply -var="instance_type=t2.large"` (should fail) |

---

## 🛡️ Security Best Practices

✅ **SSH access restricted** to your IP only  
✅ **DB access restricted** to web SG only  
✅ **Private subnets** use NAT for outbound  
✅ **S3 versioning & encryption** enabled  
✅ **Public access** to S3 blocked  
✅ **IAM roles** follow least-privilege  

---

## 📊 Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    AWS VPC (10.0.0.0/16)                │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │         Public Subnets (10.0.1-2.0/24)           │  │
│  │  ┌─────────────────┐      ┌─────────────────┐   │  │
│  │  │   ALB (port 80) │      │   NAT Gateway   │   │  │
│  │  └────────┬─────────┘      └─────────────────┘   │  │
│  │           │                                       │  │
│  │  ┌────────▼──────────────────────────────────┐   │  │
│  │  │  Target Group (Health Check: /)           │   │  │
│  │  │  - Attached to ASG                        │   │  │
│  │  └────────┬──────────────────────────────────┘   │  │
│  │           │                                       │  │
│  │  ┌────────▼──────────────────────────────────┐   │  │
│  │  │  ASG (min:1, max:3, desired:1)            │   │  │
│  │  │  - Launch Template (Nginx + stress-ng)    │   │  │
│  │  │  - CPU Alarms (scale-out: 60%, scale-in:20%) │  │
│  │  └────────┬──────────────────────────────────┘   │  │
│  │           │                                       │  │
│  │  ┌────────▼──────────┐  ┌───────────────────┐   │  │
│  │  │  EC2 Web Server   │  │ EC2 Web Server    │   │  │
│  │  │  (10.0.1/24)      │  │ (10.0.2/24)       │   │  │
│  │  └───────────────────┘  └───────────────────┘   │  │
│  │                                                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │       Private Subnets (10.0.10-11.0/24)          │  │
│  │                                                  │  │
│  │  ┌────────────────────┐  ┌─────────────────┐   │  │
│  │  │ EC2 Database Server│  │                 │   │  │
│  │  │ (10.0.10/24)       │  │  Reserved       │   │  │
│  │  │ MySQL 3306         │  │                 │   │  │
│  │  └────────────────────┘  └─────────────────┘   │  │
│  │         ↑                                        │  │
│  │         │ MySQL (from Web SG only)              │  │
│  │         └────────────────────────────────────┐  │  │
│  │                                              │  │  │
│  └──────────────────────────────────────────────┼──┘  │
│                                                 │      │
├─────────────────────────────────────────────────┼──────┤
│                Internet Gateway                 │      │
├─────────────────────────────────────────────────┼──────┤
│                                                 │      │
│         S3 (TF State)      DynamoDB (Locks)    │      │
│                                                 │      │
└─────────────────────────────────────────────────┴──────┘
```

---

## 🔄 Git Workflow

```bash
# Create branches for each task
git checkout -b task1-vpc
# ... make changes ...
git add . && git commit -m "Task 1: Custom VPC with subnets and NAT Gateway"
git push origin task1-vpc

# Create PR on GitHub, review, merge to main

# For next task:
git checkout main && git pull
git checkout -b task2-ec2
# ... repeat ...
```

---

## 📝 Important Notes

⚠️ **Before Assignment Submission:**
1. Update `terraform.tfvars` with your actual IP
2. Ensure all resources are created successfully (`terraform apply`)
3. Run `terraform destroy` before final submission (cleanup resources)
4. After viva: `terraform apply` to re-create infrastructure for demo

⚠️ **AWS Costs:**
- This setup uses mostly free-tier eligible resources (t3.micro)
- Monitor your AWS account for charges
- Always destroy when not in use

---

## 🐛 Troubleshooting

**Error: "my_ip is required"**
```bash
# Set your IP in terraform.tfvars
curl ifconfig.me  # Get your IP
# Then update terraform.tfvars: my_ip = "YOUR.IP.HERE/32"
```

**Error: "Invalid instance type"**
```bash
# Only these types are allowed: t3.micro, t3.small, t3.medium
terraform apply -var="instance_type=t3.micro"
```

**Cannot SSH to instance**
```bash
# Check security group allows your IP
terraform output web_server_public_ip
# Verify your IP in my_ip variable matches: curl ifconfig.me
```

**S3 backend migration issues**
```bash
# Make sure bucket is created first
terraform apply -auto-approve
# Then uncomment backend in main.tf with correct bucket name
terraform init -migrate-state
```

---

## 📚 References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Packer AWS Builder](https://www.packer.io/plugins/builders/amazon)
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/WhatIsCloudWatch.html)

---

**Last Updated:** April 2026  
**Assignment:** DevOps 3 — Terraform AWS Infrastructure
