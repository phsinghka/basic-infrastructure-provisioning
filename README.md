# Terraform Project 5: Basic Infrastructure Provisioning

## Overview

This project provisions a basic infrastructure on AWS using Terraform, simulating a real-world scenario for deploying a web application. The infrastructure includes:

- **Virtual Private Cloud (VPC)** with public and private subnets
- **Internet Gateway** and **NAT Gateway**
- **Security Groups** for web servers
- **EC2 Instances** with Nginx installed via provisioners
- **Remote Backend** using S3 for state management
- **Outputs** for essential information


## Directory Structure

```
terraform-project-5/
├── backend.tf
├── main.tf
├── variables.tf
├── outputs.tf
├── provisioners/
│   └── setup.sh
├── terraform.tfvars
├── .gitignore
└── README.md
```

- **backend.tf**: Configures the remote backend.
- **main.tf**: Main Terraform configuration for resources.
- **variables.tf**: Declares input variables.
- **outputs.tf**: Defines output values.
- **provisioners/setup.sh**: Script to set up the EC2 instance.
- **terraform.tfvars**: Overrides default variable values.
- **.gitignore**: Specifies files to ignore in version control.
- **README.md**: Project documentation.

## Setup Instructions

### 1. Clone the Repository

```bash
cd basic-infrastructure-provisioning
```

Replace `"your-ssh-key-name"` with your actual SSH key pair name in AWS.

### 2. Initialize Terraform

Initialize the project and configure the remote backend:

```bash
terraform init
```

### 3. Validate the Configuration

Ensure there are no syntax errors:

```bash
terraform validate
```

### 4. Plan the Deployment

Review the changes Terraform will make:

```bash
terraform plan -out=tfplan
```

### 5. Apply the Configuration

Provision the resources:

```bash
terraform apply tfplan
```

### 6. Verify Deployment

- **Access the Web Application:**

  Open your browser and navigate to the public IP address output by Terraform. You should see:

  ```
  <h1>Terraform Provisioned Web Server</h1>
  ```

- **SSH into the EC2 Instance:**

  ```bash
  ssh -i ~/.ssh/id_rsa ec2-user@<public_ip>
  ```

  Verify Nginx is running:

  ```bash
  sudo systemctl status nginx
  ```

## Cleanup

To remove all provisioned resources and avoid unnecessary charges:

```bash
terraform destroy
```

**⚠️ Warning:** This action will permanently delete all resources created by this configuration. Ensure you no longer need them before proceeding.

## Security Considerations

- **Secure SSH Access:**
  - Restrict SSH (`port 22`) access to trusted IP addresses only.
  - Use strong key pairs and protect your private keys.

- **Sensitive Data:**
  - Avoid hardcoding sensitive information in Terraform files.
  - Use variables and secure methods to manage credentials.

- **S3 Bucket Security:**
  - Enable encryption for your S3 bucket.
  - Restrict access to the S3 bucket to necessary IAM roles only.

- **IAM Roles and Policies:**
  - Assign least privilege permissions to IAM roles used by Terraform.


Happy Terraforming!
