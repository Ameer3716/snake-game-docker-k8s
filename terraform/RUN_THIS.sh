# Quick Execution Guide - Run These Commands in Order in Git Bash

# ===================================================================================================
# PART 1: INITIAL SETUP (5 minutes)
# ===================================================================================================

cd f:/Semester8/Devops_Assign_2/snake-game/terraform

# Screenshot 1.1: Verify Terraform files
echo "=== TASK 1 SETUP ==="
ls -la *.tf

# Screenshot 1.2: Verify AWS credentials
aws sts get-caller-identity

# Screenshot 1.3: Initialize Terraform
terraform init

# ===================================================================================================
# PART 2: DEPLOY INFRASTRUCTURE (15 minutes)
# ===================================================================================================

# Screenshot 2.1: Terraform Plan
echo "=== TASK 1-6: TERRAFORM PLAN ==="
terraform plan

# Take screenshot when you see "Plan: 59 to add, 0 to change, 0 to destroy"

# Screenshot 2.2: Terraform Apply (this takes ~10-15 minutes)
echo "=== DEPLOYING INFRASTRUCTURE ==="
terraform apply -auto-approve

# Take screenshot when you see "Apply complete! Resources: 59 added"

# ===================================================================================================
# PART 3: TASK 1 SCREENSHOTS - VPC (Inside terminal)
# ===================================================================================================

echo ""
echo "========== TASK 1: VPC WITH NAT GATEWAY =========="
echo ""

# Screenshot 1-T1.1: Show outputs
terraform output vpc_id
terraform output public_subnet_ids
terraform output private_subnet_ids
terraform output nat_gateway_id

# Screenshot 1-T1.2: Show all VPC resources
terraform state list | grep -i "vpc\|subnet\|nat\|route\|igw\|eip"

echo "✓ Go to AWS Console → VPC → Your VPCs → [VPC ID from above]"
echo "✓ Screenshot: VPC overview"
echo "✓ Screenshot: Subnets tab (4 subnets)"
echo "✓ Screenshot: Route tables tab"
echo "✓ Click public route table → Screenshot routes (0.0.0.0/0 → IGW)"
echo "✓ Click private route table → Screenshot routes (0.0.0.0/0 → NAT)"

# ===================================================================================================
# PART 4: TASK 2 SCREENSHOTS - EC2 & SECURITY GROUPS (Inside terminal)
# ===================================================================================================

echo ""
echo "========== TASK 2: EC2 & SECURITY GROUPS =========="
echo ""

# Screenshot 2-T2.1: Show outputs
WEB_IP=$(terraform output -raw web_server_public_ip)
DB_IP=$(terraform output -raw db_server_private_ip)
echo "Web Server Public IP: $WEB_IP"
echo "DB Server Private IP: $DB_IP"

# Screenshot 2-T2.2: Show key pair
ls -lah devops-key.pem

# Screenshot 2-T2.3: Fix key permissions if needed
chmod 400 devops-key.pem

echo "✓ Go to AWS Console → VPC → Security Groups"
echo "✓ Screenshot: Search 'web-server-sg' → Inbound Rules (SSH 22, HTTP 80, HTTPS 443 from 0.0.0.0/0)"
echo "✓ Screenshot: Outbound Rules"
echo "✓ Screenshot: Search 'db-server-sg' → Inbound Rules (MySQL 3306, SSH 22 from web-sg)"
echo "✓ Go to AWS Console → EC2 → Instances"
echo "✓ Screenshot: Both instances running (web-server with public IP, db-server with private IP)"

# ===================================================================================================
# PART 5: SSH TO WEB SERVER & TEST NGINX
# ===================================================================================================

echo ""
echo "========== SSH TO WEB SERVER =========="
echo ""
echo "About to SSH to: $WEB_IP"
echo "Press Enter to SSH or Ctrl+C to skip..."
echo "Command: ssh -i devops-key.pem ubuntu@$WEB_IP"
echo ""

# Screenshot 3-T2.4: SSH connection
ssh -i devops-key.pem ubuntu@$WEB_IP

# Inside web server terminal:
echo ""
echo "=== INSIDE WEB SERVER ==="
echo ""

# Screenshot 3-T2.5: Test Nginx
curl localhost

# Screenshot 3-T2.6: Show instance info
curl -I localhost

# Exit
exit

echo "✓ Screenshot captured: Nginx working"

# ===================================================================================================
# PART 6: TEST VALIDATION ERROR
# ===================================================================================================

echo ""
echo "========== TASK 2: VALIDATION ERROR TEST =========="
echo ""

# Screenshot 4-T2.7: Invalid instance type (SHOULD FAIL!)
echo "Testing invalid instance type (expect error)..."
terraform apply -var="instance_type=t2.large" -auto-approve

# Screenshot shows: Error about invalid instance_type

# Reapply correct configuration
echo ""
echo "Reapplying with correct configuration..."
terraform apply -auto-approve

# ===================================================================================================
# PART 7: TASK 3 SCREENSHOTS - S3 BUCKET
# ===================================================================================================

echo ""
echo "========== TASK 3: S3 BUCKET =========="
echo ""

# Screenshot 5-T3.1: Show S3 bucket name
S3_BUCKET=$(terraform output -raw s3_bucket_name)
echo "S3 Bucket: $S3_BUCKET"

# Screenshot 5-T3.2: List S3 buckets
aws s3 ls

# Screenshot 5-T3.3: List objects in bucket
aws s3api list-objects-v2 --bucket $S3_BUCKET

echo "✓ Go to AWS Console → S3"
echo "✓ Click on: $S3_BUCKET"
echo "✓ Screenshot: Properties tab → Versioning (ENABLED)"
echo "✓ Screenshot: Properties tab → Encryption (AES256 ENABLED)"
echo "✓ Screenshot: Objects tab → terraform.tfstate file"
echo "✓ Click on terraform.tfstate file"
echo "✓ Screenshot: File metadata and size"
echo "✓ Go to AWS Console → DynamoDB → Tables"
echo "✓ Screenshot: terraform-state-lock table exists"

# ===================================================================================================
# PART 8: TASK 4 SCREENSHOTS - AUTO SCALING (Takes 10+ minutes)
# ===================================================================================================

echo ""
echo "========== TASK 4: AUTO SCALING GROUP =========="
echo ""

# Screenshot 6-T4.1: Current configuration
terraform output asg_name
terraform output asg_desired_capacity

# Screenshot 6-T4.2: Scale to 2 instances
echo "Scaling ASG to 2 instances..."
terraform apply -var="desired_capacity=2" -auto-approve

# Wait for instances to launch
echo "Waiting for instances to launch (2-3 minutes)..."
sleep 120

# Screenshot 6-T4.3: Check instances
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names web-asg \
  --query 'AutoScalingGroups[0].Instances[*].[InstanceId,LifecycleState]' \
  --output table

echo "✓ Go to AWS Console → EC2 → Auto Scaling Groups"
echo "✓ Click: web-asg"
echo "✓ Screenshot: Overview (Desired=2, Current=2, Min=1, Max=3)"
echo "✓ Screenshot: Instances tab (2 running instances)"
echo "✓ Click: Activity tab"
echo "✓ Screenshot: Scaling events (2 'Creating instance' messages)"

# ===================================================================================================
# PART 9: STRESS TEST & ALARMS (IMPORTANT!)
# ===================================================================================================

echo ""
echo "========== STRESS TEST & CLOUDWATCH ALARMS =========="
echo ""

# Get ASG instance
ASG_INSTANCE=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names web-asg \
  --query 'AutoScalingGroups[0].Instances[0].InstanceId' \
  --output text)

ASG_IP=$(aws ec2 describe-instances \
  --instance-ids $ASG_INSTANCE \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo "ASG Instance IP: $ASG_IP"
echo ""
echo "Command: ssh -i devops-key.pem ubuntu@$ASG_IP"
echo "Press Enter to SSH..."
echo ""

# Screenshot 7-T4.4: SSH to ASG instance
ssh -i devops-key.pem ubuntu@$ASG_IP

# Inside ASG instance:
echo ""
echo "=== INSIDE ASG INSTANCE ==="
echo ""

# Install stress tool
sudo apt-get update -y
sudo apt-get install -y stress-ng

echo ""
echo "=== STARTING STRESS TEST ==="
echo "Stress test will run for 5 minutes..."
echo "CPU should reach 80-100%"
echo ""

# Screenshot 8-T4.5: Start stress test
stress-ng --cpu 2 --timeout 300s &

# Get PID
STRESS_PID=$!
echo "Stress PID: $STRESS_PID"

# Show high CPU
sleep 5
top -b -n 1 | head -20

# Exit and let stress continue in background for 5 minutes
exit

# In main terminal:
echo ""
echo "✓ ASG instance is now under stress"
echo "✓ In another terminal, go to: AWS Console → CloudWatch → Alarms"
echo "✓ Screenshot: Before stress → cpu-utilization-high in OK state"
echo "✓ Wait 2-3 minutes for CPU alarm to trigger"
echo "✓ Screenshot: cpu-utilization-high in ALARM state"
echo "✓ Screenshot: Alarm history showing state changes"
echo ""
echo "Stress test will end automatically in 5 minutes..."
echo ""
echo "Meanwhile:"
echo "✓ Go to EC2 → Auto Scaling Groups → web-asg → Activity"
echo "✓ Screenshot: Watch for new 'Creating instance' message (scale-out)"
echo ""

# Wait for stress to end and scale-down
sleep 360

# Verify scale-down
echo ""
echo "After 6 minutes, instances should start scaling down..."
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names web-asg \
  --query 'AutoScalingGroups[0].[DesiredCapacity,Instances[*].InstanceId]' \
  --output table

echo "✓ Screenshot: ASG has scaled back to 1 instance"
echo "✓ Go to CloudWatch → Alarms"
echo "✓ Screenshot: cpu-utilization-high back to OK state"

# ===================================================================================================
# PART 10: TASK 5 SCREENSHOTS - LOAD BALANCER
# ===================================================================================================

echo ""
echo "========== TASK 5: APPLICATION LOAD BALANCER =========="
echo ""

# Screenshot 9-T5.1: Get ALB DNS
ALB_DNS=$(terraform output -raw alb_dns_name)
echo "ALB DNS: $ALB_DNS"

# Screenshot 9-T5.2: Test load balancing
echo ""
echo "Testing load balancer (should show different instance IDs)..."
for i in {1..10}; do
  echo "Request $i:"
  curl -s http://$ALB_DNS | grep "Instance ID"
  sleep 1
done

echo ""
echo "✓ Go to AWS Console → EC2 → Load Balancers"
echo "✓ Click: web-alb"
echo "✓ Screenshot: ALB Details (DNS name, Active state)"
echo "✓ Go to EC2 → Target Groups"
echo "✓ Click: web-target-group"
echo "✓ Screenshot: Health Check Configuration"
echo "✓ Screenshot: Targets tab (2 healthy targets)"
echo ""
echo "Open browser and visit: http://$ALB_DNS"
echo "✓ Screenshot 1: First load (Instance ID: i-xxxxx)"
echo "✓ Refresh page (Ctrl+F5)"
echo "✓ Screenshot 2: Second load (Instance ID: i-yyyyy) - Different!"
echo "✓ This proves load balancing works!"

# ===================================================================================================
# PART 11: TASK 6 SCREENSHOTS - MODULES
# ===================================================================================================

echo ""
echo "========== TASK 6: TERRAFORM MODULES =========="
echo ""

# Screenshot 10-T6.1: Show module code
cat module_usage.tf

# Screenshot 10-T6.2: Show cross-module references
grep "module\." module_usage.tf

# Screenshot 10-T6.3: Show module structure
find modules -name "*.tf" | sort

# Screenshot 10-T6.4: Show module outputs
terraform output | grep module

# Screenshot 10-T6.5: Show terraform plan with modules
terraform plan | grep "module\."

echo "✓ Screenshots captured showing:"
echo "✓ - module_usage.tf with cross-module references"
echo "✓ - module directory structure"
echo "✓ - Terraform plan using modules"

# Optional Packer:
echo ""
echo "OPTIONAL: Build Packer AMI (takes ~10 minutes)"
echo "Uncomment and run if you want:"
echo "cd packer && packer init . && packer build build.pkr.hcl"

# ===================================================================================================
# PART 12: CLEANUP
# ===================================================================================================

echo ""
echo "========== CLEANUP =========="
echo ""

# Screenshot 11-CLEANUP.1: Destroy all resources
echo "Destroying all infrastructure..."
terraform destroy -auto-approve

# Screenshot 11-CLEANUP.2: Verify empty state
echo ""
echo "Verifying all resources destroyed..."
terraform state list

echo ""
echo "✓ All infrastructure destroyed!"
echo "✓ Screenshots captured for all tasks!"
echo ""
echo "Next steps:"
echo "1. Organize all screenshots by task"
echo "2. Create a document with all screenshots and descriptions"
echo "3. Submit to your instructor"
echo ""
