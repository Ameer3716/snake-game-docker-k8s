# 📸 ASSIGNMENT SUBMISSION GUIDE - All Screenshots & Commands

## 🎯 What You Need to Submit

**Deliverables for each task (6 tasks total):**
- Screenshots of AWS Console resources
- Screenshots of terminal commands
- Terminal output showing successful execution
- Error messages and validation
- Load testing results
- Module structure screenshots

---

## 📂 Files Created for You

Inside your `terraform/` directory, you now have these guide files:

### 1. **SCREENSHOT_COMMANDS.sh** 
   - All bash commands organized by task
   - Copy each command and run in Git Bash
   - Commands show exactly what to screenshot

### 2. **SCREENSHOT_CHECKLIST.md**
   - Detailed checklist for each task
   - Exactly which screenshots to take
   - What each screenshot should show
   - Total ~61 screenshots needed

### 3. **RUN_THIS.sh** (RECOMMENDED - Use this!)
   - **STEP-BY-STEP GUIDE** to run everything in order
   - Organized by parts (setup, deploy, testing, cleanup)
   - Tells you when/what to screenshot
   - Most user-friendly option

### 4. **AWS_CONSOLE_GUIDE.md**
   - Step-by-step AWS Console navigation
   - Screenshots to take from console
   - Tips for good screenshots
   - Troubleshooting help

### 5. **README.md**
   - Complete project documentation
   - Architecture overview
   - All resource details

### 6. **VIVA_GUIDE.md**
   - Expected viva questions & answers
   - Live demo commands
   - Interview prep

---

## 🚀 QUICK START - How to Get All Screenshots

### Step 1: Open Git Bash
```bash
cd f:/Semester8/Devops_Assign_2/snake-game/terraform
```

### Step 2: Run the guide script
```bash
bash RUN_THIS.sh
```

**This script will:**
1. Deploy infrastructure (15 minutes)
2. Show you when to take screenshots from terminal
3. Pause and tell you to take AWS Console screenshots
4. Run all tests (SSH, load balancing, scaling)
5. Clean up resources

---

## 📋 Screenshots Needed By Task

### **TASK 1: VPC (7 screenshots)**
- Terraform plan output ✓
- Terraform apply completion ✓
- VPC overview from console
- Public route table (shows IGW)
- Private route table (shows NAT Gateway)
- Subnets list (4 subnets)
- Traffic flow diagram (document)

**Commands:**
```bash
terraform plan
terraform apply -auto-approve
terraform output
```

**Console:** AWS → VPC

---

### **TASK 2: EC2 & Security Groups (12 screenshots)**
- Terraform plan output
- Terraform apply completion
- SSH terminal connection
- Nginx welcome page (curl output)
- Web security group inbound rules
- Web security group outbound rules
- DB security group inbound rules
- DB security group outbound rules
- EC2 instances running (console)
- Web server details (public IP)
- DB server details (private IP)
- **Validation error** (invalid instance type) ⭐ IMPORTANT

**Commands:**
```bash
terraform output web_server_public_ip
ssh -i devops-key.pem ubuntu@<IP>
curl localhost  # Inside web server
terraform apply -var="instance_type=t2.large"  # Should FAIL
```

**Console:** AWS → VPC → Security Groups, AWS → EC2 → Instances

---

### **TASK 3: S3 Bucket (7 screenshots)**
- S3 bucket name (terraform output)
- S3 bucket listed (aws s3 ls)
- S3 bucket properties - Versioning ENABLED
- S3 bucket properties - Encryption ENABLED
- S3 bucket properties - Block Public Access ENABLED
- terraform.tfstate file in bucket
- DynamoDB table (terraform-state-lock)

**Commands:**
```bash
terraform output s3_bucket_name
aws s3 ls
```

**Console:** AWS → S3, AWS → DynamoDB

---

### **TASK 4: Auto Scaling (15 screenshots)**
- ASG outputs (name, desired capacity, alarm names)
- ASG scaled to 2 instances
- ASG instances (2 running)
- ASG activity history (scaling events)
- CloudWatch alarm BEFORE stress (OK state)
- CloudWatch alarm DURING stress (ALARM state)
- CloudWatch alarm history (state changes)
- SSH to ASG instance
- stress-ng command running
- Terminal showing high CPU usage
- Alarm back to OK after stress ends
- ASG scaled back to 1 instance
- CloudWatch metrics graph
- Activity history showing scale-out event
- Activity history showing scale-in event

**Commands:**
```bash
terraform apply -var="desired_capacity=2" -auto-approve
ssh -i devops-key.pem ubuntu@<ASG_IP>
stress-ng --cpu 2 --timeout 300s &
```

**Console:** AWS → EC2 → Auto Scaling Groups, AWS → CloudWatch → Alarms

---

### **TASK 5: Load Balancer (10 screenshots)**
- ALB DNS name (terraform output)
- ALB details from console
- ALB active state
- Target group configuration
- Health check settings
- Targets - Instance 1 Healthy
- Targets - Instance 2 Healthy
- Browser - First request (shows Instance ID 1)
- Browser - Second request after refresh (shows Instance ID 2)
- Load distribution test (different IDs)

**Commands:**
```bash
ALB_DNS=$(terraform output -raw alb_dns_name)
for i in {1..10}; do curl -s http://$ALB_DNS | grep "Instance ID"; done
```

**Browser:** Visit http://<ALB_DNS>

**Console:** AWS → EC2 → Load Balancers, AWS → EC2 → Target Groups

---

### **TASK 6: Modules (10 screenshots)**
- module_usage.tf code (show cross-module references)
- Grep module references output
- Modules directory structure
- VPC module variables
- Security module main.tf
- Compute module files
- Terraform plan showing modules
- Module outputs (module_vpc_id, etc.)
- Packer build.pkr.hcl file
- Terraform state list (shows module resources)

**Commands:**
```bash
cat module_usage.tf
grep "module\." module_usage.tf
find modules -name "*.tf"
terraform plan | grep module
terraform output | grep module
```

**Console:** No specific console, mostly terminal screenshots

---

## 📸 How to Screenshot in Windows

### **Option 1: Snipping Tool (Built-in)**
1. Press: `Windows + Shift + S`
2. Draw rectangle around area to capture
3. Screenshot auto-saved to clipboard
4. Paste in Word/Document

### **Option 2: Print Screen**
1. Press: `Print Screen` key
2. Open Paint or Word
3. Paste: `Ctrl + V`
4. Save as PNG

### **Option 3: Terminal Screenshot**
1. Right-click terminal → Select All (`Ctrl + A`)
2. Right-click → Copy (`Ctrl + Shift + C`)
3. Paste into Word document

### **Option 4: Browser/Console Screenshot**
1. Right-click → Screenshot option (modern browsers)
2. Or use browser dev tools (F12)

---

## ✅ Pre-Submission Checklist

Before you submit, ensure you have:

- [ ] All 61+ screenshots organized by task
- [ ] Each screenshot labeled clearly
- [ ] Terraform plan output screenshot
- [ ] Terraform apply completion screenshot
- [ ] AWS Console screenshots for each task
- [ ] Terminal/SSH screenshots
- [ ] Error message screenshot (invalid instance type)
- [ ] Load balancing test showing different instance IDs
- [ ] Scaling events in ASG activity history
- [ ] CloudWatch alarm state transitions
- [ ] stress-ng command running screenshot
- [ ] Module code showing cross-module references
- [ ] All resources destroyed at the end

---

## 🔄 Execution Timeline

**Total time: ~90-120 minutes**

1. **Setup** (5 min) - Initialize Terraform
2. **Deploy** (15 min) - terraform apply
3. **Task 1 Screenshots** (5 min) - VPC outputs + console
4. **Task 2 Screenshots** (15 min) - SSH, Nginx, error test
5. **Task 3 Screenshots** (5 min) - S3 and DynamoDB console
6. **Task 4 Screenshots** (40 min) - Scale, stress test, alarms
7. **Task 5 Screenshots** (10 min) - ALB and load balancing
8. **Task 6 Screenshots** (10 min) - Modules and code
9. **Cleanup** (10 min) - terraform destroy

**Total: ~115 minutes**

---

## 📝 Document Organization Example

### For your submission document:

```
ASSIGNMENT 3: TERRAFORM AWS INFRASTRUCTURE
Student: [Your Name]
Date: [Date]

TASK 1: VPC WITH SUBNETTING AND NAT GATEWAY
[Screenshot 1.1: Terraform Plan]
[Screenshot 1.2: Terraform Apply]
[Screenshot 1.3: VPC Overview Console]
...
Description of traffic flow:
- Private instance sends traffic to NAT Gateway
- NAT Gateway forwards to Internet Gateway
- Response comes back via NAT Gateway
...

TASK 2: SECURITY GROUPS AND EC2
[Screenshot 2.1: Web Security Group Rules]
...
SSH Terminal Connection:
[Terminal Screenshot]
Output: Nginx welcome page shown
...

[Continue for all 6 tasks]

CLEANUP:
[Screenshot: terraform destroy complete]
[Screenshot: terraform state list empty]
```

---

## 🎓 Tips for Best Presentation

1. **Organize screenshots chronologically** by task
2. **Add descriptive captions** under each screenshot
3. **Highlight key elements** in screenshots (arrows, boxes)
4. **Include terminal outputs** for commands
5. **Group related screenshots** together
6. **Show state transitions** (before/after for scaling and alarms)
7. **Document is professional** - use proper formatting
8. **Explain what each screenshot shows** in 1-2 sentences

---

## 🆘 If Something Goes Wrong

**Issue: "Terraform can't find configuration"**
- Solution: Ensure you're in `terraform/` directory
- Run: `pwd` to verify location
- Should show: `F:\Semester8\Devops_Assign_2\snake-game\terraform`

**Issue: "AWS credentials error"**
- Solution: Run `aws configure` again
- Verify: `aws sts get-caller-identity`

**Issue: "Instance type validation error expected"**
- This is CORRECT! Take a screenshot
- It proves validation is working

**Issue: "ASG alarm not in ALARM state"**
- Wait 2-3 minutes after stress test starts
- CloudWatch metrics lag behind slightly
- Refresh CloudWatch page

**Issue: "Can't SSH to instance"**
- Verify: Web server is in running state
- Check: Security group allows SSH from your IP
- Ensure: `devops-key.pem` has correct permissions (chmod 400)

---

## 📚 Complete File Reference

All commands in one place:

**For deployment:**
- `terraform init`
- `terraform plan`
- `terraform apply -auto-approve`

**For verification:**
- `terraform output`
- `aws s3 ls`
- `aws ec2 describe-instances`
- `aws autoscaling describe-auto-scaling-groups`
- `aws elbv2 describe-target-groups`

**For testing:**
- `ssh -i devops-key.pem ubuntu@<IP>`
- `curl http://<ALB_DNS>`
- `stress-ng --cpu 2 --timeout 300s`

**For cleanup:**
- `terraform destroy -auto-approve`

---

## 🎉 Ready to Start?

**Run this to get all screenshots:**

```bash
cd f:/Semester8/Devops_Assign_2/snake-game/terraform
bash RUN_THIS.sh
```

**Or follow detailed checklist:**
- Open: SCREENSHOT_CHECKLIST.md
- Follow: Each task section
- Take: Screenshots when instructed

---

**Good luck with your assignment! 🚀**

All the infrastructure, documentation, and testing guides are prepared for you.
Just run the commands and take screenshots as instructed!

Questions? Check:
1. VIVA_GUIDE.md - Most common Q&A
2. README.md - Complete documentation
3. AWS_CONSOLE_GUIDE.md - AWS navigation help
