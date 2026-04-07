# DevOps Assignment 3 - Screenshot Checklist for Each Task

## TASK 1: Custom VPC with Subnetting and NAT Gateway

### Screenshots to Take:

1. **Terraform Plan Output**
   ```bash
   terraform plan -out=tfplan.txt
   ```
   Screenshot: Show the plan with all VPC resources (aws_vpc, aws_subnet x4, aws_internet_gateway, aws_nat_gateway, aws_route_table, etc.)
   Look for: "Plan: XX to add, 0 to change, 0 to destroy"

2. **Terraform Apply Output**
   ```bash
   terraform apply -auto-approve
   ```
   Screenshot: Show completion with "Apply complete! Resources: XX added, 0 changed, 0 destroyed"

3. **Terraform Outputs**
   ```bash
   terraform output
   ```
   Screenshot: Show vpc_id, public_subnet_ids, private_subnet_ids, nat_gateway_id

4. **AWS Console - VPC Details**
   - Go to: AWS Console → VPC → Your VPCs
   - Click: Your VPC ID (from terraform output)
   - Screenshot 1: VPC details showing CIDR 10.0.0.0/16
   - Screenshot 2: Subnets tab showing 4 subnets
   - Screenshot 3: Route Tables tab

5. **AWS Console - Public Route Table**
   - Click: Route table with public subnets
   - Screenshot: Show route with destination 0.0.0.0/0 → Internet Gateway

6. **AWS Console - Private Route Table**
   - Click: Route table with private subnets
   - Screenshot: Show route with destination 0.0.0.0/0 → NAT Gateway

7. **Traffic Flow Diagram** (Document this in report)
   ```
   Private Instance (10.0.10.0/24)
       ↓
   Route Table: 0.0.0.0/0 → NAT Gateway
       ↓
   NAT Gateway (10.0.1.0/24 in public subnet)
       ↓
   Internet Gateway
       ↓
   Internet (0.0.0.0/0)
   ```

---

## TASK 2: Security Groups and EC2 Instance Deployment

### Screenshots to Take:

1. **Terraform Plan - Task 2 (Key Pair + EC2)**
   ```bash
   terraform plan
   ```
   Screenshot: Show resources being created (tls_private_key, aws_key_pair, aws_instance x2, aws_security_group x2)

2. **Terraform Apply Complete**
   ```bash
   terraform apply -auto-approve
   ```
   Screenshot: Show "Apply complete! Resources: XX added"

3. **Terraform Outputs - Task 2**
   ```bash
   terraform output
   ```
   Screenshot: Show:
   - web_server_public_ip
   - db_server_private_ip
   - key_pair_name
   - web_server_id
   - db_server_id

4. **SSH Key Verification**
   ```bash
   ls -lah devops-key.pem
   ```
   Screenshot: Show devops-key.pem exists with correct permissions (0400)

5. **AWS Console - Web Security Group**
   - Go to: AWS Console → VPC → Security Groups
   - Search for: "web-server-sg"
   - Screenshot 1: Inbound Rules tab showing:
     - SSH (22) from 0.0.0.0/0
     - HTTP (80) from 0.0.0.0/0
     - HTTPS (443) from 0.0.0.0/0
   - Screenshot 2: Outbound Rules tab

6. **AWS Console - DB Security Group**
   - Search for: "db-server-sg"
   - Screenshot 1: Inbound Rules tab showing:
     - MySQL (3306) from web-server-sg
     - SSH (22) from web-server-sg
   - Screenshot 2: Outbound Rules tab

7. **AWS Console - EC2 Instances**
   - Go to: AWS Console → EC2 → Instances
   - Screenshot: Show both instances running:
     - web-server (with public IP)
     - db-server (with private IP)

8. **SSH to Web Server**
   ```bash
   WEB_IP=$(terraform output -raw web_server_public_ip)
   ssh -i devops-key.pem ubuntu@$WEB_IP
   ```
   Screenshots:
   - Terminal screenshot showing successful SSH connection
   - Cursor should be in ubuntu@web-server terminal

9. **Nginx Welcome Page**
   Inside the web server terminal:
   ```bash
   curl localhost
   ```
   Screenshot: Show the HTML output:
   ```html
   <h1>Web Server</h1><p>Instance ID: i-xxxxxxxxxxxx</p>
   ```

10. **Exit Web Server**
    ```bash
    exit
    ```

11. **Invalid Instance Type Error** (IMPORTANT!)
    ```bash
    terraform apply -var="instance_type=t2.large" -auto-approve
    ```
    Screenshot: Capture the validation error:
    ```
    Error: Invalid value for variable
    ...
    instance_type must be one of: t3.micro, t3.small, t3.medium.
    ```

12. **Reapply Correct Configuration**
    ```bash
    terraform apply -auto-approve
    ```
    Screenshot: Show "Apply complete!" message

---

## TASK 3: S3 Bucket with Remote State

### Screenshots to Take:

1. **Terraform Outputs - Task 3**
   ```bash
   terraform output
   ```
   Screenshot: Show:
   - s3_bucket_name
   - s3_bucket_arn
   - dynamodb_table_name

2. **S3 Bucket CLI List**
   ```bash
   aws s3 ls
   ```
   Screenshot: Show your bucket in the list

3. **S3 Bucket Contents**
   ```bash
   S3_BUCKET=$(terraform output -raw s3_bucket_name)
   aws s3api list-objects-v2 --bucket $S3_BUCKET
   ```
   Screenshot: Show terraform.tfstate file listed

4. **AWS Console - S3 Bucket Properties**
   - Go to: AWS Console → S3
   - Search for: Your bucket name (from terraform output)
   - Click: Bucket name
   - Click: Properties tab
   - Scroll down and take screenshots:
     - Screenshot 1: Versioning - ENABLED
     - Screenshot 2: Default Encryption - AES256 ENABLED
     - Screenshot 3: Block Public Access - ALL ENABLED

5. **AWS Console - S3 Objects**
   - In same bucket
   - Click: Objects tab
   - Screenshot: Show terraform.tfstate file listed
   - Click on: terraform.tfstate
   - Screenshot: Show file size, upload date, metadata

6. **AWS Console - S3 Bucket Versions**
   - Click: Versions tab
   - Screenshot: Show version history (if versioning has created versions)

7. **AWS Console - DynamoDB Table**
   - Go to: AWS Console → DynamoDB → Tables
   - Search for: "terraform-state-lock"
   - Screenshot 1: Table exists and shows hash key "LockID"
   - Screenshot 2: Items tab (may be empty or show locks)

---

## TASK 4: Auto Scaling Group with CloudWatch Alarms

### Screenshots to Take:

1. **Terraform Outputs - Task 4**
   ```bash
   terraform output
   ```
   Screenshot: Show:
   - asg_name: web-asg
   - asg_desired_capacity: 1
   - cpu_high_alarm_name: cpu-utilization-high
   - cpu_low_alarm_name: cpu-utilization-low

2. **Scale ASG to 2 Instances**
   ```bash
   terraform apply -var="desired_capacity=2" -auto-approve
   ```
   Screenshot: Show "Apply complete! Resources: 0 added, 1 changed, 0 destroyed"

3. **Check Instances**
   ```bash
   aws autoscaling describe-auto-scaling-groups \
     --auto-scaling-group-names web-asg \
     --query 'AutoScalingGroups[0].[Instances[*].InstanceId]' \
     --output table
   ```
   Screenshot: Show 2 instance IDs

4. **AWS Console - ASG Details**
   - Go to: AWS Console → EC2 → Auto Scaling Groups
   - Click: "web-asg"
   - Screenshot 1: Overview showing Desired=2, Current=2, Min=1, Max=3
   - Screenshot 2: Instances tab showing 2 running instances

5. **AWS Console - ASG Activity History**
   - In same ASG detail page
   - Click: Activity tab
   - Screenshot: Show "Creating instances..." and "Creating instance..." messages
   - Should show 2 recent events (one for each instance scaled up)

6. **Get ASG Instance IP**
   ```bash
   ASG_INSTANCE=$(aws autoscaling describe-auto-scaling-groups \
     --auto-scaling-group-names web-asg \
     --query 'AutoScalingGroups[0].Instances[0].InstanceId' \
     --output text)
   ASG_IP=$(aws ec2 describe-instances --instance-ids $ASG_INSTANCE \
     --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
   echo "ASG Instance IP: $ASG_IP"
   ```
   Screenshot: Show the IP address

7. **SSH to ASG Instance**
   ```bash
   ssh -i devops-key.pem ubuntu@$ASG_IP
   ```
   Screenshot: Show successful SSH connection

8. **Install Stress Test Tool**
   Inside ASG instance terminal:
   ```bash
   sudo apt-get update -y
   sudo apt-get install -y stress-ng
   ```
   Screenshot: Show installation output

9. **Run Stress Command** (IMPORTANT!)
   ```bash
   stress-ng --cpu 2 --timeout 300s &
   ```
   Screenshot 1: Show stress-ng running
   Screenshot 2: Show instance details (top, uptime, etc.) showing high CPU

10. **Leave Terminal Open** and open new terminal for CloudWatch monitoring

11. **AWS Console - CloudWatch Alarms**
    - Go to: AWS Console → CloudWatch → Alarms
    - Search for: "cpu-utilization-high"
    - Wait 2-3 minutes for CPU to spike
    - Screenshot 1: Alarm in INSUFFICIENT_DATA state (before stress)
    - Screenshot 2: Alarm in ALARM state (after stress - during high CPU)
    - Screenshot 3: Show alarm details

12. **AWS Console - Alarm History**
    - While alarm is in ALARM state
    - In same alarm details page
    - Click: History tab
    - Screenshot: Show state transitions (OK → INSUFFICIENT_DATA → ALARM)

13. **Back to ASG Instance Terminal**
    ```bash
    # Wait for stress-ng to complete (5 minutes)
    # Or kill it early:
    pkill stress-ng
    exit
    ```
    Screenshot: Show stress test completed or killed

14. **AWS Console - ASG Activity After Scaling**
    - Go back to: EC2 → Auto Scaling Groups → web-asg → Activity
    - Screenshot: Show new scaling events:
      - "Launching instance..." (scale out due to high CPU)
      - Wait 4-5 minutes
      - "Terminating instance..." (scale down due to low CPU)

15. **AWS Console - Alarm Back to OK**
    - Go to: CloudWatch → Alarms
    - Screenshot: Show cpu-utilization-high alarm back to OK state

---

## TASK 5: Application Load Balancer with Health Checks

### Screenshots to Take:

1. **Terraform Outputs - Task 5**
   ```bash
   terraform output
   ```
   Screenshot: Show:
   - alb_dns_name: web-alb-XXXXX.us-east-1.elb.amazonaws.com
   - alb_arn
   - target_group_arn

2. **Get ALB DNS and Test**
   ```bash
   ALB_DNS=$(terraform output -raw alb_dns_name)
   echo "ALB DNS: $ALB_DNS"
   curl http://$ALB_DNS
   ```
   Screenshots:
   - Screenshot 1: Echo showing ALB_DNS value
   - Screenshot 2: curl output showing HTML with Instance ID

3. **Test Load Distribution**
   ```bash
   for i in {1..10}; do
     echo "Request $i:"
     curl -s http://$ALB_DNS | grep "Instance ID"
     sleep 1
   done
   ```
   Screenshot: Show different instance IDs appearing (proves load balancing)

4. **AWS Console - Load Balancers**
   - Go to: AWS Console → EC2 → Load Balancers
   - Screenshot: Show "web-alb" in the list with:
     - State: Active
     - DNS name shown
     - 2 Availability Zones

5. **AWS Console - ALB Details**
   - Click: "web-alb"
   - Screenshot 1: Details showing DNS name and status
   - Screenshot 2: Network tab showing subnets and security groups

6. **AWS Console - Target Groups**
   - Go to: EC2 → Target Groups
   - Click: "web-target-group"
   - Screenshot 1: Basic configuration showing:
     - Protocol: HTTP
     - Port: 80
     - VPC: Your VPC

7. **AWS Console - Health Checks**
   - In same Target Group page
   - Click: Health check settings (in Description tab or edit)
   - Screenshot: Show health check configuration:
     - Protocol: HTTP
     - Path: /
     - Port: traffic port
     - Healthy threshold: 2
     - Unhealthy threshold: 3
     - Interval: 30
     - Timeout: 5
     - Matcher: 200

8. **AWS Console - Registered Targets**
   - In same Target Group page
   - Click: Targets tab
   - Screenshot: Show 2 registered targets:
     - Both showing "Healthy" status
     - Instance IDs visible
     - Showing port 80

9. **Browser Test - ALB Load Balancing**
   - Open browser
   - Navigate to: http://<ALB_DNS> (replace with your DNS)
   - Screenshot 1: Shows instance ID (e.g., i-1234567890abcdef0)
   - Refresh page (Ctrl+F5)
   - Screenshot 2: Shows different instance ID (e.g., i-0987654321fedcba)
   - This proves load balancing is working!

10. **AWS Console - Monitoring**
    - In Target Group page
    - Scroll to: Monitoring section
    - Screenshot: Show healthy/unhealthy host count

---

## TASK 6: Terraform Modules and Packer

### Screenshots to Take:

1. **Show Module Usage in Code**
   ```bash
   cat module_usage.tf
   ```
   Screenshot: Show the file content with:
   - module "vpc" block
   - module "security" block
   - module "compute" block
   - Cross-module references like:
     - module.vpc.vpc_id
     - module.security.web_sg_id
     - module.vpc.public_subnet_ids[0]

2. **Show Cross-Module References**
   ```bash
   grep "module\." module_usage.tf
   ```
   Screenshot: Show lines with module references:
   - vpc_id = module.vpc.vpc_id
   - subnet_id = module.vpc.public_subnet_ids[0]
   - security_group_ids = [module.security.web_sg_id]

3. **Show Module Directory Structure**
   ```bash
   find modules -name "*.tf" | sort
   ```
   Screenshot: Show:
   - modules/vpc/main.tf
   - modules/vpc/variables.tf
   - modules/vpc/outputs.tf
   - modules/security/main.tf
   - modules/security/variables.tf
   - modules/security/outputs.tf
   - modules/compute/main.tf
   - modules/compute/variables.tf
   - modules/compute/outputs.tf

4. **Show VPC Module Variables**
   ```bash
   cat modules/vpc/variables.tf
   ```
   Screenshot: Show input variables (vpc_cidr, public_subnet_cidrs, private_subnet_cidrs, etc.)

5. **Show VPC Module Main**
   ```bash
   head -50 modules/vpc/main.tf
   ```
   Screenshot: Show VPC resource definition

6. **Show Module Outputs**
   ```bash
   cat modules/vpc/outputs.tf
   ```
   Screenshot: Show outputs (vpc_id, public_subnet_ids, private_subnet_ids, nat_gateway_id)

7. **Terraform Plan - Shows Modules**
   ```bash
   terraform plan
   ```
   Screenshot: Look for lines showing:
   - module.vpc.aws_vpc.main
   - module.security.aws_security_group.web
   - module.compute.aws_instance.this
   This proves modules are being used!

8. **Module Outputs in Terraform Output**
   ```bash
   terraform output | grep module
   ```
   Screenshots: Show:
   - module_vpc_id
   - module_public_subnet_ids
   - module_web_sg_id
   - module_web_public_ip
   - module_web_instance_id

9. **Show Packer Configuration (Optional)**
   ```bash
   cat packer/build.pkr.hcl
   ```
   Screenshot: Show Packer HCL file with:
   - source "amazon-ebs" "ubuntu"
   - provisioner "shell" with inline commands
   - Installs: nginx, curl, stress-ng

10. **Packer Build (Optional - takes 10 minutes)**
    ```bash
    cd packer
    packer init .
    packer build build.pkr.hcl
    ```
    Screenshot 1: Show "Build complete!" message
    Screenshot 2: Show output AMI ID (ami-XXXXXXXXX)

---

## CLEANUP

### Final Screenshots:

1. **Destroy All Resources**
   ```bash
   cd terraform
   terraform destroy -auto-approve
   ```
   Screenshot: Show "Destroy complete! Resources: XX destroyed"

2. **Verify Empty State**
   ```bash
   terraform state list
   ```
   Screenshot: Show (empty output - no resources)

---

## Summary of Screenshots Needed:

**Task 1:** 7 screenshots (plan, apply, outputs, VPC console x4)
**Task 2:** 12 screenshots (plan, apply, outputs, SSH, Nginx, error, SG rules x2, EC2 console)
**Task 3:** 7 screenshots (outputs, S3 CLI, S3 console x4, DynamoDB)
**Task 4:** 15 screenshots (outputs, scale, ASG console x2, activity x2, SSH, stress, CloudWatch x4, alarm history)
**Task 5:** 10 screenshots (outputs, DNS test, load distribution, ALB console, TG console x5)
**Task 6:** 10 screenshots (module code, directory structure, plan, outputs, packer x2)

**Total: ~61 screenshots**

---

## Notes:
- Use Windows Print Screen or Snipping Tool for desktop screenshots
- Use terminal screenshot tools or copy-paste output
- Label each screenshot clearly with task and step number
- Include timestamp in screenshots when possible
- For load balancing tests, show multiple requests to prove different instance IDs
- For scaling tests, show before/after instance counts
- For alarms, capture state transitions (OK → INSUFFICIENT_DATA → ALARM → OK)
