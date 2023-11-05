
# VPC Configuration
resource "aws_vpc" "splunkvpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "splunkvpc"
  } 
}

# Subnet Configuration
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.splunkvpc.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.availability_zones[0]

 tags = {
    Name = "splunk public Subnet"
  } 
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.splunkvpc.id
  cidr_block              = var.private_subnet_1_cidr_block
  availability_zone       = var.availability_zones[1]

  
  tags = {
    Name = "splunk Private Subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.splunkvpc.id
  cidr_block              = var.private_subnet_2_cidr_block
  availability_zone       = var.availability_zones[2]

  tags = {
    Name = "splunk Private Subnet 2"
  }
}

# Internet Gateway Configuration
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.splunkvpc.id
}

# Route Table Configuration
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.splunkvpc.id



  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Subnet Association Configuration
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "private_subnet_1_association" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "private_subnet_2_association" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.my_route_table.id
}


# Security Group Configuration
resource "aws_security_group" "my_security_group" {
  name        = "splunk-sg"
  description = "My Security Group"

  vpc_id = aws_vpc.splunkvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   dynamic "ingress" {
    for_each = var.splunk_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# # EC2 Instance Configuration
resource "aws_instance" "splunk_instances" {
  count         = var.instance_count
  ami           = var.ubuntu_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id

  vpc_security_group_ids = [aws_security_group.my_security_group.id]

  key_name               = var.key_pair_name
  
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    echo "Setting hostname to: ${var.instance_tags[count.index].value}.${var.domain}"
    hostnamectl set-hostname ${var.instance_tags[count.index].value}.${var.domain}
    apt install git -y

    #useradd -m splunk_user && sudo usermod -aG sudo splunk_user && echo "splunk_user ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
    
    # Generate SSH key pair for the splunk_user
    sudo -u splunk_user ssh-keygen -t rsa -b 4096 -C 'splunk_user@example.com' -f /home/splunk_user/.ssh/id_rsa -N ''
    cat /home/splunk_user/.ssh/id_rsa.pub >> /home/splunk_user/.ssh/authorized_keys
    
    # Add the ansible user's public key to the splunk_user's authorized_keys file
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDuMxFk4YOXIBL6LLsYPC01rdPgutJNhPQp5hTtW2OgFKCCYZ28UeDD+unzjlY53wZVG35nimoyVvIK+DlN0ZnvQsEFVbS8doIPCS2BYiVK0luBZpyvNgS5uMCIWKb1/FE644Tx6IBegeRR92+xjW8jWf43X7B5feneYoM80+GIsOCVv05xA1W4FRe0RJMIVsGOjnZ15TZWhWSdIC6/Wg/6PXm4rJwnPsulFTXUzgHaPcz3tumrSDEJJ4Tlhepe9dEKKa4ITWwy4fBLttIRB+vhvQTJa4RJwi3J+ZlhBXpUzfdbsYYGY7k50hbOU0+BNN17oiHNU9RNeRsQhlw3s1S+CMZ+IdsBIhJyDaawVkMxcfwshatX1G0Dg5MtA6LBr/7A3v3z3AEgJbs6Ew5TzMC4ykr8DOaVoYApJ0IpehfplbHAm3F9ZCScW9VgeCTDwcn0BI5KuqgBxLGYmVPQZgh2UuORUzp/XBFAFrK97hrB2/NyM0qS0DcbDl08YGeJCPE= ansible@ansible-master" >> /home/splunk_user/.ssh/authorized_keys
    
    # Install Splunk
    git clone https://github.com/layamba25/SplunkEngineerTraining.git
    cd SplunkEngineerTraining/Scripts/BashScripts
    chmod +x *.sh
    if [ "${var.instance_tags[count.index].value}" == "*universal*" ]; then
      ./splunk_forwarder_installer.sh
    else
      ./splunk_enterprise_installer.sh
    fi

   
  EOF

  # tags = {
  #   Name = "${var.instance_tags[count.index].value}.${var.domain}"
    
  # }
  tags = merge(
    {
      "Name" = "${var.instance_tags[count.index].value}.${var.domain}"
    },
    var.instance_tags[count.index].value == "searchhead01" ? {
      "Instance" = "SearchHead"
    } : {},
    contains([lower(var.instance_tags[count.index].value)], "searchhead01") ? {
      "Instance" = "SearchHead"
    } : {},
    contains([lower(var.instance_tags[count.index].value)], "searchhead02") ? {
      "Instance" = "SearchHead"
    } : {},
    ################################
    
    contains([lower(var.instance_tags[count.index].value)], "index01") ? {
      "Instance" = "Indexer"
    } : {},
    
    contains([lower(var.instance_tags[count.index].value)], "index02") ? {
      "Instance" = "Indexer"
    } : {},
    
    contains([lower(var.instance_tags[count.index].value)], "index02") ? {
      "Instance" = "Indexer"
    } : {},
    ################################

  )

}