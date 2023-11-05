
 variable "vpc_cidr_block" {
   description = "CIDR block for the VPC"
   default     = "10.0.0.0/16"
 }

 variable "public_subnet_cidr_block" {
   description = "CIDR block for the public subnet"
   default     = "10.0.1.0/24"
 }

 variable "private_subnet_1_cidr_block" {
   description = "CIDR block for private subnet 1"
   default     = "10.0.2.0/24"
 }

 variable "private_subnet_2_cidr_block" {
   description = "CIDR block for private subnet 2"
   default     = "10.0.3.0/24"
 }

 variable "ubuntu_ami" {
   description = "AMI ID for Ubuntu"
   default     = "ami-024e6efaf93d85776"
 }

 variable "instance_type" {
   description = "EC2 instance type"
    default     = "t2.large"
  #  default = "t2.micro"
 }

 variable "key_pair_name" {
   description = "Key pair name"
   default     = "SplunkTraining"
 }

 variable "public_key_path" {
   description = "Path to the public key file"
   default     =  "C:\\Users\\Enior\\OneDrive\\Desktop\\splunk-infra\\splunk.pem"

 }


 variable "instance_count" {
   description = "Number of EC2 instances to create"
   default     = 11
    # default = 2
 }


 variable "availability_zones" {
   description = "List of availability zones"
   type        = list(string)
   default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
 }

 variable "control_node_hostname" {
   description = "Hostname for the control node"
   default     = "control-node"
 }


 variable "instance_tags" {
   description = "List of targeted nodes tags for EC2 instances"
   type        = list(map(string))
   default = [
     {
       "key"   = "Name"
       "value" = "searchhead01"
     },
     {
       "key"   = "Name"
       "value" = "searchhead02"
     }
      ,
      {
       "key"   = "Name"
       "value" = "indexer01"
      },
      {
        "key"   = "Name"
        "value" = "indexer02"
      },
      {
        "key"   = "Name"
        "value" = "indexer03"
      },
      {
        "key"   = "Name"
        "value" = "clustermanager"
      },
      {
        "key"   = "Name"
        "value" = "deploymentserver"
      },
      {
        "key"   = "Name"
        "value" = "deployer"
      },
      {
        "key"   = "Name"
        "value" = "heavyforwarder"
      },
      {
        "key"   = "Name"
        "value" = "linuxuniversalforwarder"
      },
      {
        "key"   = "Name"
        "value" = "license-server"
      }
   ]
 }

 variable "domain" {
     description = "Domain Name of the Company"
     default = "<domain>"
 }

 variable "splunk_ports" {
   type        = list(number)
   default = ["8000", "8089", "9997", "8088", "9998"]
 }

 variable "splunk_download" {
   default =  "https://download.splunk.com/products/splunk/releases/9.0.5/linux/splunk-9.0.5-e9494146ae5c-Linux-x86_64.tgz"
 }

 variable "splunk_password" {
   default = "admin12345"
 }

#  variable "ansible_public_key" {
#    description = "Public key for the Ansible instance"
#    default     = "ssh-rsa <ansible_public_key_content>"
#  }

