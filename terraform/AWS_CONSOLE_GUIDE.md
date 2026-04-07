# AWS Console Navigation Guide for Screenshots

## How to Take AWS Console Screenshots

### TASK 1: VPC & Network Screenshots

#### VPC Overview
1. Go to: AWS Management Console → VPC
2. Click: "Your VPCs" (left sidebar)
3. Look for: vpc-XXXXX
4. **SCREENSHOT**: Shows VPC with CIDR 10.0.0.0/16
5. Click: VPC ID to open details
6. **SCREENSHOT**: VPC details page

#### Subnets
1. In VPC details page
2. Click: "Subnets" tab
3. **SCREENSHOT**: Shows 4 subnets:
   - prod-public-1 (10.0.1.0/24)
   - prod-public-2 (10.0.2.0/24)
   - prod-private-1 (10.0.10.0/24)
   - prod-private-2 (10.0.11.0/24)

#### Public Route Table
1. In VPC details page
2. Click: "Route Tables" tab
3. Look for: public route table
4. Click: Route table ID
5. **SCREENSHOT 1**: Route table details
6. **SCREENSHOT 2**: Routes showing:
   - Destination: 10.0.0.0/16 → Target: local
   - Destination: 0.0.0.0/0 → Target: Internet Gateway ID

#### Private Route Table
1. In VPC details page
2. Click: "Route Tables" tab
3. Look for: private route table (associated with private subnets)
4. Click: Route table ID
5. **SCREENSHOT 1**: Route table details
6. **SCREENSHOT 2**: Routes showing:
   - Destination: 10.0.0.0/16 → Target: local
   - Destination: 0.0.0.0/0 → Target: NAT Gateway ID

---

### TASK 2: Security Groups & EC2 Screenshots

#### Web Security Group
1. Go to: VPC → Security Groups
2. In search box, type: "web-server-sg"
3. Click: the security group result
4. **SCREENSHOT 1**: Inbound Rules tab showing:
   - Type: SSH, Protocol: TCP, Port: 22, Source: 0.0.0.0/0
   - Type: HTTP, Protocol: TCP, Port: 80, Source: 0.0.0.0/0
   - Type: HTTPS, Protocol: TCP, Port: 443, Source: 0.0.0.0/0
5. Click: "Outbound Rules" tab
6. **SCREENSHOT 2**: Outbound Rules showing default allow-all rule

#### Database Security Group
1. In same page
2. Search box: type "db-server-sg"
3. Click: the security group result
4. **SCREENSHOT 1**: Inbound Rules tab showing:
   - Type: Custom TCP Rule, Port: 3306, Source: SG web-server-sg
   - Type: SSH, Protocol: TCP, Port: 22, Source: SG web-server-sg
5. Click: "Outbound Rules" tab
6. **SCREENSHOT 2**: Outbound Rules (default allow-all)

#### EC2 Instances
1. Go to: EC2 → Instances
2. **SCREENSHOT**: Shows instances list with:
   - web-server: State: Running, Public IPv4: 3.239.185.63
   - db-server: State: Running, Private IPv4: 10.0.10.18
3. Click: web-server
4. **SCREENSHOT**: Instance details showing:
   - Public IP address
   - Private IP address
   - Subnet ID
   - Security Groups

---

### TASK 3: S3 Bucket Screenshots

#### S3 Bucket
1. Go to: S3 → Buckets
2. Look for: bucket name (devops-tf-state-XXXX)
3. Click: bucket name
4. **SCREENSHOT 1**: Bucket overview
5. Click: "Properties" tab
6. Scroll down to: "Versioning"
7. **SCREENSHOT 2**: Versioning section showing "ENABLED"
8. Scroll to: "Default encryption"
9. **SCREENSHOT 3**: Encryption showing "AES256"
10. Scroll to: "Block Public Access"
11. **SCREENSHOT 4**: All toggles showing "ON"

#### terraform.tfstate File
1. In bucket details
2. Click: "Objects" tab
3. Look for: terraform.tfstate
4. **SCREENSHOT 1**: Shows terraform.tfstate file in objects list
5. Click: terraform.tfstate file
6. **SCREENSHOT 2**: File details showing:
    - Size: XX bytes
    - Last Modified: date/time
    - Storage Class: Standard
    - Version ID: (if versioning enabled)

#### DynamoDB Lock Table
1. Go to: DynamoDB → Tables
2. Search or look for: terraform-state-lock
3. Click: table name
4. **SCREENSHOT 1**: Table overview showing:
    - Table Name: terraform-state-lock
    - Primary Key: LockID
    - Item Count: (may be 0 or show lock items)
5. Click: "Items" tab
6. **SCREENSHOT 2**: Shows any lock items (usually empty unless applying during screenshot)

---

### TASK 4: Auto Scaling & CloudWatch Screenshots

#### Auto Scaling Group Overview
1. Go to: EC2 → Auto Scaling Groups
2. Click: "web-asg"
3. **SCREENSHOT 1**: Overview tab showing:
    - Desired: 2
    - Current: 2
    - Min: 1
    - Max: 3
    - Instances: 2 running

#### ASG Instances Tab
1. In same page
2. Click: "Instances" tab
3. **SCREENSHOT**: Shows 2 instances:
    - Instance 1 ID: i-XXXXX, Status: InService
    - Instance 2 ID: i-YYYYY, Status: InService

#### ASG Activity Tab
1. In same page
2. Click: "Activity" tab
3. **SCREENSHOT**: Shows activity history:
    - "Launching instance i-XXXXX"
    - "Launching instance i-YYYYY"
    - (More activities as you scale up/down)

#### CloudWatch Alarms - Before Stress
1. Go to: CloudWatch → Alarms
2. Search: "cpu-utilization-high"
3. Click: alarm name
4. **SCREENSHOT 1**: Alarm details showing:
    - Alarm Name: cpu-utilization-high
    - State: OK
    - State Reason: "Threshold Crossed: no datapoints were received for X alarm"

#### CloudWatch Alarms - During Stress (Wait for CPU spike)
1. Stay in same alarm page
2. Wait 2-3 minutes for CPU to spike
3. Refresh page (or wait for auto-refresh)
4. **SCREENSHOT 2**: Alarm details showing:
    - State: ALARM
    - State Reason: "Threshold Crossed: 1 datapoint [85.5 (04/06/26 18:15:00 UTC)] was greater than or equal to threshold (60.0)."

#### CloudWatch Alarm History
1. In same alarm page
2. Click: "History" tab or scroll down
3. **SCREENSHOT**: Shows state transitions:
    - First entry: OK
    - Second entry: INSUFFICIENT_DATA
    - Third entry: ALARM
    - Later entry: OK (after scaling down and CPU drops)

#### CloudWatch Metrics
1. Go to: CloudWatch → Metrics
2. Click: "EC2"
3. Click: "AutoScaling Group metrics"
4. Look for: web-asg
5. Click: CPUUtilization metric
6. **SCREENSHOT 1**: Graph showing low CPU (around 5-10%)
7. (Return after stress test)
8. **SCREENSHOT 2**: Graph showing high CPU spike (around 80-100%)

---

### TASK 5: Load Balancer Screenshots

#### Elastic Load Balancers
1. Go to: EC2 → Load Balancers
2. Look for: web-alb
3. **SCREENSHOT 1**: Load Balancers list showing:
    - Name: web-alb
    - State: Active
    - DNS name: web-alb-XXXXX.us-east-1.elb.amazonaws.com

#### ALB Details
1. Click: web-alb name
2. **SCREENSHOT**: Details tab showing:
    - Load Balancer Name
    - DNS name
    - State: Active
    - Scheme: internet-facing
    - Type: Application
    - IP Address Type: ipv4
    - VPC ID
    - Availability Zones: 2

#### Target Groups
1. Go to: EC2 → Target Groups
2. Look for: web-target-group
3. Click: target group name
4. **SCREENSHOT 1**: Basic configuration showing:
    - Target Group Name: web-target-group
    - Protocol: HTTP
    - Port: 80
    - VPC: Your VPC ID

#### Health Check Settings
1. In target group details
2. Look for: Health Checks section (in Description or edit)
3. **SCREENSHOT**: Health check configuration showing:
    - Protocol: HTTP
    - Path: /
    - Port: traffic port
    - Healthy threshold: 2
    - Unhealthy threshold: 3
    - Timeout: 5 seconds
    - Health check interval: 30 seconds
    - Matcher: 200

#### Registered Targets
1. In target group details
2. Click: "Targets" tab
3. **SCREENSHOT**: Targets list showing:
    - Instance 1: i-XXXXX, Port 80, Status: Healthy
    - Instance 2: i-YYYYY, Port 80, Status: Healthy
    - (Both should be healthy with green checkmarks)

#### Browser Test - ALB Load Balancing
1. Open web browser (Chrome, Firefox, Edge)
2. In address bar: http://web-alb-XXXXX.us-east-1.elb.amazonaws.com
   (Replace with your ALB DNS from terraform output)
3. Press Enter
4. **SCREENSHOT 1**: Shows Nginx welcome page with:
    ```html
    <h1>Web Server</h1>
    <p>Instance ID: i-09c7e4d4b2dd36d20</p>
    ```
5. Press Ctrl+F5 (hard refresh to bypass cache)
6. **SCREENSHOT 2**: Shows same page but with different Instance ID:
    ```html
    <h1>Web Server</h1>
    <p>Instance ID: i-0f9f2a59e37467afb</p>
    ```
7. The different instance IDs prove load balancing is working!

#### ALB Monitoring
1. In ALB details
2. Scroll down to: Monitoring section
3. **SCREENSHOT**: Shows:
    - Active Connection Count
    - Client TLS Connection Count
    - Request Count
    - Target Connection Count

---

### TASK 6: Modules (Less AWS Console, More Terminal)

No specific AWS Console screenshots needed for Task 6. The screenshots are mainly from:
1. Terminal showing module_usage.tf code
2. Terminal showing directory structure
3. Terminal showing terraform plan output
4. Terminal showing module outputs

---

### General AWS Console Tips

**To Take Good Screenshots:**

1. **Make windows full screen** for better visibility
2. **Zoom browser to 100%** (not scaled down)
3. **Use Windows Snipping Tool** or built-in screenshot
   - Press: Windows + Shift + S to snipper full screenshot
   - Then: Click and drag to select area
4. **Add labels to screenshots** (you can use Paint or Word)
   - Annotate what's important
   - Draw arrows pointing to key items
5. **Show state transitions** when possible
   - Before state: Alarm OK
   - After state: Alarm ALARM
6. **Include time/date** if visible in screenshot
7. **Clear any sensitive data** before submission

**Screenshot Naming Convention:**
- Task1_VPC_Overview.png
- Task2_WebSecurityGroup_InboundRules.png
- Task3_S3_Versioning.png
- Task4_ASG_Instances.png
- Task5_ALB_Targets.png
- Task6_Modules_Usage.png

---

### Quick Links in AWS Console

**Save these links:**
- VPC: https://console.aws.amazon.com/vpc/
- EC2: https://console.aws.amazon.com/ec2/
- S3: https://console.aws.amazon.com/s3/
- DynamoDB: https://console.aws.amazon.com/dynamodb/
- CloudWatch: https://console.aws.amazon.com/cloudwatch/
- Auto Scaling: https://console.aws.amazon.com/ec2/
  (Then navigate to Auto Scaling Groups in left sidebar)

---

### Troubleshooting Screenshots

**If you don't see the resource:**
- Verify region is correct (us-east-1)
- Refresh the page (F5)
- Check terraform outputs for correct IDs
- Ensure terraform apply completed successfully

**If alarm is not in ALARM state:**
- Wait 2-3 minutes after stress test starts
- Refresh CloudWatch page
- Verify stress-ng is still running on EC2 instance
- Check CloudWatch → Metrics to see CPU usage spike
