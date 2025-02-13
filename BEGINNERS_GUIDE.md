# Bastion Host Project: A Complete Beginner's Guide

## What is this Project About?

Imagine you have a private server (like your personal computer) that contains sensitive information. You want to access it remotely but don't want to expose it directly to the internet. This is where a bastion host comes in!

### Simple Analogy
Think of it like a secure entry checkpoint:
- The bastion host is like a security guard at the entrance of a building
- Your private server is like a vault inside the building
- You need to pass through the security guard (bastion) to reach the vault (private server)

## Why Do We Need This?

1. **Security**: 
   - Direct access to private servers is dangerous
   - A bastion host acts as a single, well-protected entry point
   - All traffic must go through this controlled point

2. **Audit Trail**:
   - You can monitor who is accessing your private servers
   - Track when they accessed and what they did
   - Helpful for security and compliance

3. **Cost Effective**:
   - Only need to secure and monitor one entry point
   - Reduces the attack surface of your infrastructure

## How Does It Work?

### The Basic Flow
1. You (the user) connect to the bastion host using SSH
2. The bastion host then connects to your private server
3. All traffic flows through this secure path

```
You → Internet → Bastion Host → Private Network → Private Server
```

## Project Components Explained

### 1. Virtual Private Cloud (VPC)
- Think of this as your private neighborhood
- Has its own address range (10.0.0.0/16)
- Completely isolated from other networks

#### Why?
- Creates a secure, isolated environment
- You control what goes in and out
- Better organization of resources

### 2. Subnets
We created two types of subnets:

a) **Public Subnet (10.0.1.0/24)**:
   - Like a front yard
   - Where your bastion host lives
   - Can access the internet directly

b) **Private Subnet (10.0.2.0/24)**:
   - Like a backyard
   - Where your private server lives
   - No direct internet access

#### Why?
- Separation of concerns
- Additional layer of security
- Better network organization

### 3. Internet Gateway
- The door to the internet
- Attached to your VPC
- Allows communication with the internet

#### Why?
- Bastion host needs internet access
- You need to connect to the bastion host
- Required for SSH access

### 4. Security Groups
Think of these as firewall rules:

a) **Bastion Security Group**:
   - Allows SSH (port 22) from your IP
   - Controls who can access the bastion

b) **Private Server Security Group**:
   - Only allows SSH from the bastion
   - No other incoming connections

#### Why?
- Precise control over network traffic
- Minimize potential attack vectors
- Essential security measure

## Network Components Deep Dive

### Internet Gateway Explained
Think of the Internet Gateway (IGW) as the door to the internet for your VPC.

#### What is an Internet Gateway?
- A highly available AWS component
- Allows communication between your VPC and the internet
- Performs network address translation (NAT) for instances with public IPs

#### Setting Up Internet Gateway
```bash
# Create Internet Gateway
aws ec2 create-internet-gateway

# Attach to VPC
aws ec2 attach-internet-gateway \
    --internet-gateway-id $IGW_ID \
    --vpc-id $VPC_ID
```

#### Why Do We Need It?
1. **Public Access**:
   - Allows bastion host to receive connections from you
   - Enables software updates on bastion host
   - Permits outbound internet access

2. **Security**:
   - Only resources in public subnet can use it
   - Private subnet remains isolated
   - Acts as a gateway control point

### Route Tables In-Depth

Route tables are like traffic directors in your VPC. They determine where network traffic is directed.

#### 1. Public Route Table
```bash
# Create public route table
aws ec2 create-route-table --vpc-id $VPC_ID

# Add internet access route
aws ec2 create-route \
    --route-table-id $PUBLIC_RT_ID \
    --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID

# Associate with public subnet
aws ec2 associate-route-table \
    --route-table-id $PUBLIC_RT_ID \
    --subnet-id $PUBLIC_SUBNET_ID
```

Routes in public route table:
```
Destination         Target
0.0.0.0/0          igw-xxxxxx (Internet Gateway)
10.0.0.0/16        local
```

#### 2. Private Route Table
```bash
# Create private route table
aws ec2 create-route-table --vpc-id $VPC_ID

# Associate with private subnet
aws ec2 associate-route-table \
    --route-table-id $PRIVATE_RT_ID \
    --subnet-id $PRIVATE_SUBNET_ID
```

Routes in private route table:
```
Destination         Target
10.0.0.0/16        local
```

#### How Route Tables Work
1. **Public Subnet Routing**:
   - Traffic to VPC (10.0.0.0/16) stays local
   - All other traffic (0.0.0.0/0) goes to Internet Gateway
   - Enables two-way internet communication

2. **Private Subnet Routing**:
   - Only has local route (10.0.0.0/16)
   - No route to internet
   - Can only communicate within VPC

3. **Route Priority**:
   - Most specific route wins
   - Local routes take precedence
   - Default route (0.0.0.0/0) is last resort

#### Security Implications
1. **Public Subnet**:
   - Bastion host can receive your SSH connections
   - Can download updates and patches
   - Exposed to internet (needs strong security)

2. **Private Subnet**:
   - No direct internet access
   - Must go through bastion for updates
   - Protected from direct internet threats

#### Best Practices
1. **Route Table Management**:
   - Keep separate route tables for public/private subnets
   - Regularly audit routes
   - Document all route changes

2. **Security**:
   - Minimize number of public subnets
   - Use specific routes when possible
   - Monitor route table changes

3. **Maintenance**:
   - Regularly verify route table associations
   - Clean up unused routes
   - Keep documentation updated

## SSH Configuration Details

### Setting Up SSH Config
We created a special SSH configuration file to make connections easier:

```bash
# In ~/.ssh/config
Host bastion
    HostName <bastion-public-ip>
    User ec2-user
    IdentityFile ~/.ssh/your-key.pem

Host private-server
    HostName <private-server-private-ip>
    User ec2-user
    ProxyJump bastion
    IdentityFile ~/.ssh/your-key.pem
```

#### Why This Configuration?
- Makes connecting to servers easier (just type `ssh bastion` or `ssh private-server`)
- Automatically handles key selection
- Sets up proper jump host configuration
- Reduces chance of errors

## Security Measures We Implemented

### 1. SSH Key Authentication
- More secure than passwords
- Uses cryptographic keys
- Private key stays on your computer

### 2. fail2ban
- Blocks IP addresses that make too many failed attempts
- Prevents brute force attacks
- Automatically bans suspicious activity

### 3. SSH Hardening
- Disabled root login
- Only allow key-based authentication
- No password authentication allowed

## Automation Options

### 1. Terraform Setup
We created Terraform configurations for automated deployment:
- `main.tf`: Infrastructure definition
- `variables.tf`: Customizable variables
- `outputs.tf`: Important resource information
- `scripts/bastion_setup.sh`: Automated security configuration

### 2. Manual vs Automated Approach
We implemented both approaches:
1. Manual (AWS CLI commands) for learning and understanding
2. Terraform for reproducibility and scalability

### 3. fail2ban Configuration Details
```bash
[DEFAULT]
bantime = 3600        # Ban for 1 hour
findtime = 600        # Look at last 10 minutes
maxretry = 3          # Allow 3 retries

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/secure
```

## Step-by-Step Implementation

### 1. Setting Up the Network
```bash
# Create VPC
aws ec2 create-vpc --cidr-block 10.0.0.0/16

# Create Subnets
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.1.0/24  # Public
aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block 10.0.2.0/24  # Private
```

What's happening?
- Creating a private network space
- Dividing it into public and private areas
- Setting up network routing

### 2. Security Configuration
```bash
# Create security groups
aws ec2 create-security-group --group-name bastion-sg
aws ec2 create-security-group --group-name private-sg

# Configure rules
aws ec2 authorize-security-group-ingress --group-id $BASTION_SG_ID --protocol tcp --port 22 --cidr 0.0.0.0/0
```

What's happening?
- Creating firewall rules
- Specifying who can connect
- Setting up access controls

### 3. Creating Servers
```bash
# Launch bastion host
aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --key-name your-key --security-group-ids $BASTION_SG_ID

# Launch private server
aws ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --key-name your-key --security-group-ids $PRIVATE_SG_ID
```

What's happening?
- Creating virtual servers
- Applying security settings
- Setting up SSH access

### 4. Security Hardening
```bash
# Install fail2ban
sudo yum install -y fail2ban

# Configure SSH
sudo nano /etc/ssh/sshd_config
# Set: PermitRootLogin no
# Set: PasswordAuthentication no
```

What's happening?
- Adding brute force protection
- Hardening SSH configuration
- Improving security

## How to Use the Bastion Host

1. **Connect to Bastion**:
```bash
ssh -i your-key.pem ec2-user@bastion-ip
```

2. **Connect to Private Server** (through bastion):
```bash
ssh -i your-key.pem ec2-user@private-server-ip
```

## Troubleshooting Guide

### 1. SSH Connection Issues
```bash
# Check SSH agent
ssh-add -l

# Test bastion connection
ssh -vv bastion

# Test private server connection
ssh -vv private-server
```

### 2. Security Group Verification
```bash
# Check inbound rules
aws ec2 describe-security-group-rules \
    --filters Name="group-id",Values="$SECURITY_GROUP_ID"
```

### 3. Network Connectivity
```bash
# Test from bastion
ping 8.8.8.8          # Internet connectivity
ping private-server   # Internal connectivity
```

## Project Extensions

### 1. Planned Improvements
- Multi-factor authentication (MFA) for SSH
- iptables configuration for granular traffic control
- CloudWatch monitoring setup
- Automated backup system

### 2. Additional Security Measures
- Session recording
- Access time restrictions
- IP whitelisting
- Regular security audits

## Best Practices

1. **Regular Updates**:
   - Keep systems patched
   - Update security rules
   - Monitor logs

2. **Access Control**:
   - Use strong SSH keys
   - Rotate keys regularly
   - Monitor access logs

3. **Monitoring**:
   - Check security logs
   - Monitor failed login attempts
   - Review access patterns

## Cost Management

### 1. Resource Costs
- t2.micro instances (free tier eligible)
- Data transfer charges
- Associated storage costs

### 2. Cost Optimization
- Use spot instances for non-critical workloads
- Implement auto-shutdown during non-work hours
- Monitor and optimize data transfer

## Cleaning Up

When you're done:
1. Terminate EC2 instances
2. Delete security groups
3. Delete subnets
4. Delete VPC

This prevents ongoing charges.

## Learning Resources

1. [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
2. [SSH Configuration Guide](https://www.ssh.com/ssh/config/)
3. [Security Best Practices](https://aws.amazon.com/security/security-learning/)
4. [Linux Administration](https://www.linux.org/)
