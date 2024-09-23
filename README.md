# Terraform_with_AWS
Building AWS Infrastructure using Terraform

 **Overview**
This project demonstrates how to build AWS infrastructure using Terraform, an Infrastructure as Code (IaC) tool. The configuration provisions an EC2 instance in a public subnet, sets up an Internet Gateway (IGW) for internet access, creates security groups, and configures S3 bucket access via IAM roles.

 **Prerequisites**
Before starting, ensure you have the following:

- An AWS Account with free-tier access.
- [AWS CLI](https://aws.amazon.com/cli/) and [Terraform](https://www.terraform.io/downloads) installed on your local machine.
- An IAM user with administrative privileges (ensure you have your access and secret keys).
- Basic understanding of Infrastructure as Code (IaC) concepts and Terraform.
  
 **Getting Started**

1. Clone the repository:
   
   git clone https://github.com/viju21/Terraform_with_AWS.git
   cd Terraform_with_AWS
   

2. Modify Configuration:
   - Update the AMI ID in the Terraform configuration file (`main.tf`). AMI IDs differ based on the region, so make sure to select a valid AMI for your region.
   - Ensure you give a unique name for your S3 bucket in the `s3_bucket` resource block, as S3 bucket names must be globally unique.

 Explanation of the Terraform Code

 1. VPC and Subnet Setup
The code creates an EC2 instance within a public subnet in the default VPC. By default, this setup uses the default VPC provided by AWS, which simplifies networking configuration.

 2. Internet Gateway (IGW) and Routing
- An Internet Gateway (IGW) is attached to the default VPC to allow the EC2 instance to access the internet.
- A route table is configured to direct outbound traffic from the EC2 instance through the IGW for internet connectivity.

 3. EC2 Security Groups
- A security group is created for the EC2 instance to manage inbound and outbound traffic:
  - Inbound: Ports 22 (SSH), 80 (HTTP), and 443 (HTTPS) are opened.
  - Outbound: All traffic is allowed.

 4. S3 Bucket and IAM Role
- An S3 bucket is created to store files.
- An IAM policy is defined that grants the EC2 instance permissions to interact with the S3 bucket (e.g., `GetObject`, `PutObject`, etc.).
- The policy is attached to an IAM role (`ec2_s3_role`), which is then linked to the EC2 instance via an instance profile. This allows the EC2 instance to upload and retrieve files from the S3 bucket without the need for direct AWS credentials on the instance.

 Steps to Deploy

1. Initialize Terraform:
   Run the following command to initialize Terraform and download required provider plugins:
   
   terraform init
   

2. Validate the Configuration:
   Validate the configuration to ensure there are no syntax errors:
   
   terraform validate
   

3. Apply the Terraform Plan:
   Deploy the infrastructure using the following command. This will show you the changes to be made and prompt you to confirm.
   
   terraform apply
   

4. Access the EC2 Instance:
   After successful deployment, you can access your EC2 instance via SSH:
   
   ssh -i <path_to_your_key.pem> ec2-user@<public_ip_of_your_instance>
   

 Tasks to Perform

1. Upload Files to the EC2 Instance:
   Use the `scp` command to upload files from your local machine to the EC2 instance:
   
   scp -i <path_to_your_key.pem> <local_file_path> ec2-user@<public_ip>:/home/ec2-user
   

2. Upload Files to S3:
   Once logged into the EC2 instance, create or move files and upload them to the S3 bucket:
   
   aws s3 cp /path/to/your/file s3://<your_s3_bucket_name>/
   

 Next Steps and Enhancements
- Custom VPC: Instead of using the default VPC, you could create a custom VPC with multiple subnets (public and private) for better security and flexibility.
- Auto-scaling: Integrate Auto Scaling Groups (ASG) to automatically scale your EC2 instances based on traffic.
- CloudWatch Monitoring: Set up monitoring using AWS CloudWatch for better visibility into your EC2 instance's performance and health.
- Secrets Manager: Use AWS Secrets Manager to securely store and retrieve sensitive information such as database credentials.

 Cleanup
To delete all the resources created by Terraform, run the following command:

terraform destroy
