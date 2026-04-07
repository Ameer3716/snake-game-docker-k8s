# VIVA Preparation Guide - Assignment 3: Terraform AWS Infrastructure

## 📋 Expected Questions & Answers

### TASK 1: VPC & Networking

**Q1: What is the CIDR block for your VPC?**
- A: 10.0.0.0/16 (16 million IP addresses)

**Q2: How many subnets did you create and what are their CIDR blocks?**
- A: 4 subnets total
  - Public: 10.0.1.0/24, 10.0.2.0/24
  - Private: 10.0.10.0/24, 10.0.11.0/24

**Q3: What is a NAT Gateway and why do you need it?**
- A: NAT Gateway allows private instances to access the internet while remaining unreachable from the internet. Located in public subnet, routes traffic from private subnets through itself.

**Q4: Show me how traffic flows from a private instance to the internet.**
- A: Private Instance → Route Table (0.0.0.0/0 → NAT Gateway) → NAT Gateway (in public subnet) → EIP → Internet Gateway → Internet

**Q5: What are route tables and why do we have separate ones for public and private?**
- A: Route tables define routing rules. Public can route directly to IGW, private must go through NAT for internet.

**Command to demonstrate:**
```bash
terraform output vpc_id
terraform output nat_gateway_id
terraform state list  # Show all resources
```

---

### TASK 2: EC2 & Security Groups

**Q1: Explain the security architecture (Web + DB instances)**
- A: Web server in public subnet accepts HTTP/HTTPS from internet and SSH from my IP. DB server in private subnet only accepts MySQL from web SG and SSH from web SG (bastion pattern).

**Q2: What is a security group and how is it different from NACLs?**
- A: SG is stateful firewall at instance level. NACL is stateless at subnet level. We only use SG here.

**Q3: How did you generate the SSH key pair?**
- A: Using Terraform's `tls_private_key` and `aws_key_pair` resources. Private key saved locally as devops-key.pem.

**Q4: Explain the bastion pattern.**
- A: SSH to public web server, then from there SSH to private DB server. Provides secure access without exposing private instances.

**Command to demonstrate:**
```bash
ssh -i devops-key.pem ubuntu@$(terraform output -raw web_server_public_ip)
# From inside public instance:
ssh -i ~/.ssh/devops-key.pem ubuntu@<PRIVATE_IP>
```

**Q5: Why can't the DB server be reached directly from internet?**
- A: It's in private subnet with no route to IGW, and security group only allows MySQL from web SG.

---

### TASK 3: S3 & State Management

**Q1: Why do we need remote state storage in S3?**
- A: Team collaboration, state locking to prevent conflicts, version history, backup/recovery, and security encryption.

**Q2: What is state locking and how does DynamoDB help?**
- A: Prevents multiple users from applying changes simultaneously. DynamoDB table stores locks with LockID as hash key.

**Q3: How is the state file encrypted?**
- A: Using server-side encryption with AES256 (default S3 encryption).

**Q4: What permissions did you give to EC2 for S3 access?**
- A: s3:GetObject, s3:PutObject, s3:DeleteObject, s3:ListBucket on the state bucket.

**Q5: Can you show me how to migrate to S3 backend?**
- A: Uncomment backend block in main.tf with S3 bucket name, then run `terraform init -migrate-state`.

**Commands to demonstrate:**
```bash
terraform output s3_bucket_name
terraform output dynamodb_table_name
# Go to AWS Console → S3 → your bucket → see state file + versioning
# Go to AWS Console → DynamoDB → terraform-state-lock → see LockID item
```

---

### TASK 4: Auto Scaling Group & CloudWatch Alarms

**Q1: What is the desired capacity and what happens when we change it?**
- A: Currently 1. If increased to 3, ASG will launch 2 more instances. If decreased to 1, it will terminate 2 instances.

**Q2: Explain the scaling policies and alarms.**
- A: Scale-out: CPU ≥ 60% for 2 minutes → add 1 instance. Scale-in: CPU ≤ 20% for 2 minutes → remove 1 instance.

**Q3: Why have a cooldown period?**
- A: 120 seconds cooldown prevents rapid scaling up/down (flapping) from sudden metric spikes.

**Q4: How does CloudWatch collect CPU metrics?**
- A: CloudWatch agent automatically collects CPUUtilization metric from EC2 instances every minute.

**Q5: How do you test the scaling?**
- A: SSH into instance, run `stress-ng --cpu 2 --timeout 300s`, monitor ASG activity in AWS Console.

**Commands to demonstrate:**
```bash
terraform apply -var="desired_capacity=2" -auto-approve
terraform output asg_name
# SSH into instance and run stress test
stress-ng --cpu 2 --timeout 300s &
# Watch AWS Console → EC2 → Auto Scaling → web-asg → Activity
```

---

### TASK 5: Application Load Balancer

**Q1: What is the purpose of the ALB?**
- A: Distribute incoming traffic across multiple EC2 instances. Layer 7 (application layer) load balancing with path/hostname-based routing.

**Q2: Explain the target group and health checks.**
- A: Target group groups instances for forwarding. Health check: ping path "/" every 30s, 2 successful = healthy, 3 failures = unhealthy.

**Q3: How is the ALB connected to the ASG?**
- A: Using `aws_autoscaling_attachment` resource. When new instances launch, they auto-register. When they terminate, they auto-deregister.

**Q4: How do you test load distribution?**
- A: `for i in {1..10}; do curl -s http://$ALB_DNS | grep "Instance ID"; done` — should show different instance IDs.

**Q5: What happens if all target instances become unhealthy?**
- A: ALB returns 503 Service Unavailable. In production, should have at least min replicas or trigger alarms to investigate.

**Commands to demonstrate:**
```bash
ALB=$(terraform output -raw alb_dns_name)
curl http://$ALB
# Test load distribution
for i in {1..10}; do curl -s http://$ALB | grep "Instance ID"; done
```

---

### TASK 6: Terraform Modules & Packer

**Q1: What are Terraform modules and why do you use them?**
- A: Reusable, encapsulated Terraform code. Promotes DRY principle, maintainability, and consistency across projects.

**Q2: Explain the three modules you created.**
- A:
  - VPC: Creates VPC, subnets, IGW, NAT, route tables
  - Security: Creates web and DB security groups
  - Compute: Creates EC2 instance with user data

**Q3: What is cross-module referencing?**
- A: In module_usage.tf, compute references VPC output (public_subnet_ids) and security output (web_sg_id) using `module.<name>.<output>`.

**Q4: What does Packer do?**
- A: Builds custom AMIs by launching an instance, provisioning it with software (nginx, curl, stress-ng), then creating an image.

**Q5: How do you use the Packer AMI in Terraform?**
- A: Build with `packer build`, get AMI ID from output, update terraform.tfvars ami_id, reapply terraform.

**Commands to demonstrate:**
```bash
# Show module references in module_usage.tf
cat terraform/module_usage.tf | grep "module\."

# Build Packer AMI
cd terraform/packer
packer build build.pkr.hcl
# Note the AMI ID in output (e.g., ami-0abc123...)
```

---

### GENERAL TERRAFORM QUESTIONS

**Q1: What is terraform.tfvars and why do we need it?**
- A: Stores variable values. Separates configuration from code. Can be .gitignored for sensitive data.

**Q2: What is the terraform state file and why shouldn't we commit it?**
- A: State file maps resources to infrastructure. Contains sensitive data. Should store remotely (S3) with versioning and encryption.

**Q3: What validation did you add to variables?**
- A: Instance type validation: only t3.micro, t3.small, or t3.medium allowed. Prevents typos.

**Q4: How do you destroy all infrastructure?**
- A: `terraform destroy -auto-approve` — destroys all resources created by terraform.

**Q5: Explain the difference between local variables and input variables.**
- A: Input variables (`.tf` files) are like function parameters. Can be overridden via CLI or .tfvars. Local variables are defined in modules.

---

## 🎯 Live Demo Commands

### Complete workflow to demonstrate everything:

```bash
# 1. Show code
cat terraform/main.tf | head -20
cat terraform/variables.tf
cat terraform/outputs.tf

# 2. Initialize
cd terraform
terraform init

# 3. Plan
terraform plan

# 4. Apply
terraform apply -auto-approve

# 5. Show outputs
terraform output

# 6. SSH to web server
chmod 400 devops-key.pem
ssh -i devops-key.pem ubuntu@$(terraform output -raw web_server_public_ip)

# From inside web server:
curl localhost  # See Nginx response

# 7. From web server, SSH to DB server
ssh -i ~/.ssh/devops-key.pem ubuntu@<DB_PRIVATE_IP>

# 8. Test ALB load distribution
ALB=$(terraform output -raw alb_dns_name)
for i in {1..5}; do curl -s http://$ALB | grep "Instance ID"; done

# 9. Scale up
exit  # exit from web server first
terraform apply -var="desired_capacity=2" -auto-approve

# 10. Check ASG activity
# AWS Console → EC2 → Auto Scaling → web-asg → Activity tab

# 11. Test Packer
cd packer
packer build build.pkr.hcl

# 12. Cleanup
cd ..
terraform destroy -auto-approve
```

---

## 💡 Pro Tips for Viva

1. **Know your IPs:**
   - VPC: 10.0.0.0/16
   - Public subnets: 10.0.1-2.0/24
   - Private subnets: 10.0.10-11.0/24

2. **Understand resource dependencies:**
   - IGW must exist before NAT
   - NAT depends on EIP
   - Route table associations bind subnets to routes

3. **Practice the demo at least 3 times:**
   - Run terraform apply/destroy cycle
   - Test SSH connections
   - Verify scaling
   - Know where to find resources in AWS Console

4. **Be ready to explain:**
   - Security group rules (direction, protocol, port, source)
   - Load balancer workflow (listener → target group → EC2)
   - Auto scaling triggers (CPU thresholds)
   - Module parameter passing

5. **Have these outputs ready:**
   - `terraform output` (all outputs)
   - `terraform state list` (all resources)
   - `terraform show | head -50` (current state)

6. **Common questions to prepare for:**
   - "Why t3.micro?" → Free tier, sufficient for demo
   - "Why two AZs?" → High availability
   - "Why NAT instead of direct internet?" → Private instances security
   - "Why ALB instead of Classic LB?" → Layer 7 routing, better performance

---

## ✅ Checklist Before Viva

- [ ] All 6 tasks implemented
- [ ] terraform.tfvars updated with your IP
- [ ] `terraform apply` succeeds without errors
- [ ] Can SSH to web server
- [ ] Can SSH from web to DB (bastion)
- [ ] ALB DNS is accessible
- [ ] ASG can scale up/down
- [ ] README.md is comprehensive
- [ ] All code is committed to git
- [ ] Practiced the demo 3 times
- [ ] Understand each line of Terraform code
- [ ] Ready to explain architecture diagram
