#  Cloud-Infrastructre using Terraform


>#### Infrastructure as Code(IAC) to deploy a completely reliable and automated production Environment using Terraform
![terraform-x-aws-1](https://user-images.githubusercontent.com/33370942/84769270-2facf800-aff3-11ea-8dc2-ecb87a54de58.png)

Terrafrom is the most widely used product for Infrastructure as a Service. By using terraform infrastructure handling is a piece of cake.
Let us see what we are going to work on today.
#### Table of Contents
  - [Install Terraform](#Installation)
  - [Create an security group with ssh and web ports enabled](#create-an-security-group-with-ssh-and-web-ports-enabled)
  - [Launch EC2 instance](#description)
  - [In this Ec2 instance use the key and security group which we have created](#instructions)
  - [Launch one Volume (EBS) and mount that volume into /var/www/html](#reporting-issues)
  - [Developer have uploded the code into github repo also the repo has some images](#user-privacy)
  - [Copy the github repo code into /var/www/html](#disclaimer)
  - [Create S3 bucket and copy or deploy the images from github repo into the s3 bucket and change the permission to public readable](#create-s3-bucket-and-copy-or-deploy-the-images-from-github-repo-into-the-s3-bucket-and-change-the-permission-to-public-readable)
## Installation
Download:  [Terraform](https://www.terraform.io/downloads.html)

Before creating infrastructure let's see Some Basic Terraform Commands
Go to **workspace** 
To initialize or install plugins  :

```sh
$ terraform init
```
To check the code:
```sh
$ terraform validate
```
To run or deploy:
```sh
$ terraform apply
```
To destroy the complete infrastructure:
```sh
$ terraform destroy
```

#### Create an security group with ssh and web ports enabled
#### Create S3 bucket and copy or deploy the images from github repo into the s3 bucket and change the permission to public readable
#### Launch EC2 instance
#### In this Ec2 instance use the key and security group which we have created
#### Launch one Volume (EBS) and mount that volume into /var/www/html
#### Developer have uploded the code into github repo also the repo has some images
#### Copy the github repo code into /var/www/html
#### Create S3 bucket and copy or deploy the images from github repo into the s3 bucket and change the permission to public readable
