# DevOps Assignment 3 - Complete Command Guide for Screenshots
# Run these commands in Git Bash and take screenshots for deliverables

# ===================================================================================================
# SETUP: Initial Deployment
# ===================================================================================================

cd f:/Semester8/Devops_Assign_2/snake-game/terraform

# Verify Terraform files
ls -la *.tf

# Check AWS credentials
aws sts get-caller-identity

# Initialize Terraform
terraform init

# ===================================================================================================
# TASK 1: Custom VPC with Subnetting and NAT Gateway
# ===================================================================================================

# 1. Show Terraform Plan (Screenshot the output)
terraform plan -out=tfplan.txt

# 2. Show Terraform Apply (Screenshot the output)
terraform apply -auto-approve

# 3. View VPC ID
terraform output vpc_id

# 4. View Subnets
terraform output public_subnet_ids
terraform output private_subnet_ids

# 5. Check NAT Gateway
terraform output nat_gateway_id

# 6. List all created resources
terraform state list | grep vpc
terraform state list | grep subnet
terraform state list | grep nat
terraform state list | grep route

# 7. Get VPC details (paste VPC ID in AWS Console to view route tables)
terraform output -json | grep -i vpc_id

# AWS CONSOLE ACTIONS for Task 1 Screenshots:
# 1. Go to AWS Console → VPC → Your VPCs
# 2. Click on the VPC ID from terraform output
# 3. Go to Route Tables tab, screenshot both public and private route tables
# 4. Show the routes in each table
# 5. Diagram: Private Instance → NAT Gateway → IGW → Internet

cat << 'EOF'

TASK 1 TRAFFIC FLOW DESCRIPTION:
Private Instance (10.0.10.0/24)
    ↓
Route Table: 0.0.0.0/0 → NAT Gateway
    ↓
NAT Gateway (in public subnet)
    ↓
Internet Gateway
    ↓
Internet (0.0.0.0/0)

Return traffic: Internet → IGW → NAT Gateway → Private Instance

EOF

# ===================================================================================================
# TASK 2: Security Groups and EC2 Instance Deployment
# ===================================================================================================

# 1. Get Web Server Public IP
terraform output -raw web_server_public_ip

# 2. Get DB Server Private IP
terraform output -raw db_server_private_ip

# 3. Get Security Group IDs
terraform state show aws_security_group.web_sg | grep id
terraform state show aws_security_group.db_sg | grep id

# 4. Show instance IDs
terraform output web_server_id
terraform output db_server_id

# 5. Verify SSH key exists
ls -lah devops-key.pem

# 6. Set permissions on key (if needed)
chmod 400 devops-key.pem

# AWS CONSOLE ACTIONS for Task 2 Screenshots:
# 1. Go to AWS Console → VPC → Security Groups
# 2. Search for "web-server-sg", screenshot the inbound/outbound rules
# 3. Search for "db-server-sg", screenshot the inbound/outbound rules
# 4. Go to EC2 → Instances
# 5. Screenshot both instances running (web-server and db-server)
# 6. Note: Take screenshot of web server showing public IP and running state

# TERMINAL ACTIONS for Task 2 Screenshots:

# 7. SSH to Web Server and show Nginx welcome page
WEB_IP=$(terraform output -raw web_server_public_ip)
echo "Web Server IP: $WEB_IP"

# SSH to web server (Screenshot this terminal)
ssh -i devops-key.pem ubuntu@$WEB_IP

# Inside web server terminal - run these commands (Screenshot the output):
curl localhost
# Shows: <h1>Web Server</h1><p>Instance ID: i-xxxx</p>

# Exit web server
exit

# 8. Test invalid instance type (should show validation error - Screenshot this!)
terraform apply -var="instance_type=t2.large" -auto-approve
# This will FAIL with: "instance_type must be one of: t3.micro, t3.small, t3.medium."
# SCREENSHOT THIS ERROR!

# 9. Reapply with correct type
terraform apply -auto-approve

# 10. Show Bastion pattern (SSH from web to DB)
ssh -i devops-key.pem ubuntu@$WEB_IP

# Inside web server:
ssh -i ~/.ssh/devops-key.pem ubuntu@$(terraform output -raw db_server_private_ip)
# If you get "Permission denied", just show you tried - that's fine for screenshot

exit
exit

# ===================================================================================================
# TASK 3: S3 Bucket with Remote State
# ===================================================================================================

# 1. Get S3 Bucket Name
terraform output s3_bucket_name

# 2. Get DynamoDB Table Name
terraform output dynamodb_table_name

# 3. List all S3 buckets
aws s3 ls

# 4. Get S3 bucket details
S3_BUCKET=$(terraform output -raw s3_bucket_name)
echo "S3 Bucket: $S3_BUCKET"

# 5. List objects in S3 bucket
aws s3api list-objects-v2 --bucket $S3_BUCKET

# 6. Show S3 bucket versioning
aws s3api get-bucket-versioning --bucket $S3_BUCKET

# 7. Show S3 bucket encryption
aws s3api get-bucket-encryption --bucket $S3_BUCKET

# AWS CONSOLE ACTIONS for Task 3 Screenshots:
# 1. Go to AWS Console → S3
# 2. Find your bucket (name from terraform output)
# 3. Click on bucket → Properties tab
# 4. Screenshot: Show versioning is ENABLED
# 5. Screenshot: Show encryption is ENABLED
# 6. Click on Objects tab
# 7. Screenshot: Show terraform.tfstate file
# 8. Click on terraform.tfstate file
# 9. Screenshot: Show file size and metadata
# 10. Go to DynamoDB
# 11. Find table "terraform-state-lock"
# 12. Screenshot: Show the table exists

# ===================================================================================================
# TASK 4: Auto Scaling Group with CloudWatch Alarms
# ===================================================================================================

# 1. Get ASG Name
terraform output asg_name

# 2. Get current desired capacity
terraform output asg_desired_capacity

# 3. Scale ASG to 2 instances
terraform apply -var="desired_capacity=2" -auto-approve

# 4. Check ASG instances
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names web-asg \
  --query 'AutoScalingGroups[0].{MinSize:MinSize,MaxSize:MaxSize,DesiredCapacity:DesiredCapacity,Instances:Instances[*].InstanceId}' \
  --output table

# 5. Get CloudWatch alarm names
terraform output cpu_high_alarm_name
terraform output cpu_low_alarm_name

# 6. Check alarm state
aws cloudwatch describe-alarms --alarm-names cpu-utilization-high --query 'MetricAlarms[0].[AlarmName,StateValue,StateReason]' --output table

# 7. SSH to one of the ASG instances
ASG_INSTANCE=$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names web-asg --query 'AutoScalingGroups[0].Instances[0].InstanceId' --output text)
ASG_IP=$(aws ec2 describe-instances --instance-ids $ASG_INSTANCE --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "ASG Instance IP: $ASG_IP"

ssh -i devops-key.pem ubuntu@$ASG_IP

# Inside ASG instance - run stress command (Screenshot this!)
sudo apt-get update -y
sudo apt-get install -y stress-ng

# Run stress test for 5 minutes
stress-ng --cpu 2 --timeout 300s &

# In another terminal window, watch CloudWatch metrics (Screenshot these!)
watch -n 30 'aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=AutoScalingGroupName,Value=web-asg \
  --start-time $(date -u -d "10 minutes ago" +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 60 \
  --statistics Average \
  --output table'

# Exit ASG instance after stress test completes
exit

# AWS CONSOLE ACTIONS for Task 4 Screenshots:
# 1. Go to AWS Console → EC2 → Auto Scaling Groups
# 2. Click on "web-asg"
# 3. Screenshot: Show 2 instances running
# 4. Click on "Activity" tab
# 5. Screenshot: Show scaling events (Launch Instance messages)
# 6. Go to CloudWatch → Alarms
# 7. Search for "cpu-utilization-high"
# 8. Screenshot: Show alarm in ALARM state (should trigger during stress test)
# 9. Go to CloudWatch → Alarms → History
# 10. Screenshot: Show alarm state changes

# ===================================================================================================
# TASK 5: Elastic Load Balancer with Health Checks
# ===================================================================================================

# 1. Get ALB DNS Name
ALB_DNS=$(terraform output -raw alb_dns_name)
echo "ALB DNS: $ALB_DNS"

# 2. Test ALB endpoint (run multiple times to show load balancing)
for i in {1..10}; do
  echo "Request $i:"
  curl -s http://$ALB_DNS | grep "Instance ID"
  sleep 1
done

# 3. Check target group health
aws elbv2 describe-target-groups \
  --names web-target-group \
  --query 'TargetGroups[0].[TargetGroupName,HealthCheckEnabled,HealthCheckProtocol,HealthCheckPath,HealthCheckPort]' \
  --output table

# 4. Check target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn) \
  --query 'TargetHealthDescriptions[*].[Target.Id,TargetHealth.State,TargetHealth.Reason]' \
  --output table

# AWS CONSOLE ACTIONS for Task 5 Screenshots:
# 1. Go to AWS Console → EC2 → Load Balancers
# 2. Find "web-alb"
# 3. Screenshot: Show ALB details (DNS name, state)
# 4. Go to EC2 → Target Groups
# 5. Click on "web-target-group"
# 6. Screenshot: Show Health Check settings
# 7. Click on "Targets" tab
# 8. Screenshot: Show 2 healthy targets (instances)
# 9. Open browser and visit: http://<ALB_DNS>
# 10. Screenshot: Show Nginx welcome page
# 11. Refresh multiple times (Ctrl+F5) and take screenshot showing different instance IDs
# 12. Show load balancing is working by seeing different instances

# TERMINAL ACTIONS:
# 1. Screenshot the loop output showing different instance IDs

# ===================================================================================================
# TASK 6: Terraform Modules and Packer
# ===================================================================================================

# 1. Show Terraform Plan using modules
terraform plan

# 2. Show module in plan output (look for "module.vpc", "module.security", "module.compute")
terraform plan | grep -i module

# 3. Show cross-module references in code
cat module_usage.tf | grep "module\."

# 4. Get module outputs
terraform output module_vpc_id
terraform output module_public_subnet_ids
terraform output module_web_sg_id
terraform output module_web_public_ip

# 5. Show module structure
ls -la modules/
ls -la modules/vpc/
ls -la modules/security/
ls -la modules/compute/

# 6. Show Packer configuration
cat packer/build.pkr.hcl

# 7. List Packer files
ls -la packer/

# AWS CONSOLE ACTIONS for Task 6 Screenshots:
# 1. Open module_usage.tf in editor
# 2. Screenshot: Show cross-module references (module.vpc.vpc_id, module.security.web_sg_id, etc.)
# 3. Screenshot: Show module directory structure in terminal

# PACKER ACTIONS (Optional - if you want to build custom AMI):
# 1. Navigate to packer directory
cd packer

# 2. Initialize Packer
packer init .

# 3. Build the AMI (will take 5-10 minutes)
# packer build build.pkr.hcl
# Screenshot the build output showing:
# - Finding base AMI
# - Launching builder
# - Provisioning
# - Creating AMI

# 4. Get the new AMI ID from output
# 5. Update terraform.tfvars with new AMI ID
# 6. Run terraform plan again with new AMI

# Return to terraform directory
cd ..

# ===================================================================================================
# CLEANUP
# ===================================================================================================

# When done with all screenshots:
terraform destroy -auto-approve

# Verify all destroyed
terraform state list
# Should show: (empty output - no resources)

echo "All infrastructure destroyed successfully!"
