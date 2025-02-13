# AWS Bastion Host Setup Project

This project demonstrates how to set up a secure bastion host architecture in AWS to safely access private infrastructure.

## Project Overview

A bastion host serves as a secure gateway for accessing private resources in your AWS infrastructure. This setup will create a bastion host in a public subnet and a private server in a private subnet, implementing secure SSH access patterns.

## Prerequisites

- AWS Account with administrative access
- AWS CLI installed and configured
- SSH key pair generation knowledge
- Basic understanding of VPC and Security Groups
- Basic Linux command line knowledge

## Architecture Components

1. **VPC Setup**
   - 1 VPC with 2 subnets (public and private)
   - Internet Gateway for public subnet
   - NAT Gateway for private subnet
   - Appropriate route tables

2. **EC2 Instances**
   - Bastion Host (t2.micro) in public subnet
   - Private Server (t2.micro) in private subnet

3. **Security**
   - Security Groups for both instances
   - Network ACLs
   - SSH key pairs
   - fail2ban for additional security

## Implementation Steps

### 1. Network Setup
1. Create VPC with CIDR block (e.g., 10.0.0.0/16)
2. Create public subnet (e.g., 10.0.1.0/24)
3. Create private subnet (e.g., 10.0.2.0/24)
4. Set up Internet Gateway and NAT Gateway
5. Configure route tables

### 2. Security Configuration
1. Create security groups:
   - Bastion Host: Allow SSH (port 22) from your IP
   - Private Server: Allow SSH only from Bastion Host
2. Generate SSH key pairs for both instances

### 3. Instance Setup
1. Launch Bastion Host:
   - Amazon Linux 2
   - t2.micro in public subnet
   - Assign elastic IP
2. Launch Private Server:
   - Amazon Linux 2
   - t2.micro in private subnet
   - No public IP

### 4. SSH Configuration
1. Configure local SSH config (~/.ssh/config):
```
Host bastion
    HostName <bastion-elastic-ip>
    User ec2-user
    IdentityFile ~/.ssh/bastion-key.pem

Host private-server
    HostName <private-server-ip>
    User ec2-user
    ProxyJump bastion
    IdentityFile ~/.ssh/private-server-key.pem
```

### 5. Security Hardening
1. Install and configure fail2ban on bastion host
2. Set up SSH session logging
3. Configure proper file permissions for SSH keys

## Testing Connection

1. Connect to bastion host:
```bash
ssh bastion
```

2. Connect to private server through bastion:
```bash
ssh private-server
```

## Security Best Practices

1. Regularly update both instances
2. Monitor SSH access logs
3. Use specific IP ranges in security groups
4. Implement proper key rotation
5. Consider implementing MFA for SSH access

## Monitoring and Maintenance

1. Set up CloudWatch for monitoring
2. Configure AWS CloudTrail for API logging
3. Regular security patches and updates
4. Monitor fail2ban logs

## Cleanup

To avoid unnecessary AWS charges:
1. Terminate EC2 instances
2. Delete Elastic IP
3. Delete NAT Gateway
4. Delete custom security groups
5. Delete VPC and associated resources

## Troubleshooting

Common issues and solutions:
1. Cannot connect to bastion host
   - Check security group rules
   - Verify SSH key permissions
   - Confirm elastic IP is properly associated

2. Cannot connect to private server
   - Verify bastion host connection
   - Check security group rules
   - Confirm ProxyJump configuration

## Additional Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [OpenSSH Documentation](https://www.openssh.com/manual.html)

## Contributing

Feel free to submit issues and enhancement requests!