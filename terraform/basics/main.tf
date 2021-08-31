provider "aws" {
  region  = "us-east-2"
}

variable "workspace_iam_roles" {
  default = {
    stage    = "arn:aws:iam::terraform:role/Terraform"
    prod     = "arn:aws:iam::terraform:role/Terraform"
  }
}


variable "cur_instance_type" {
  default = {
    stage = "t2.nano"
    prod = "t2.micro"
  }
}

locals {
  instance_count_map = {
    stage = 1
    prod = 2
  }
  instances = {
     "t3.nano" = "ami-06382629a9eb569e3"
     "t3.micro" = "ami-06382629a9eb569e3"
  }
}


resource "aws_s3_bucket" "frstudentdata" {
  # (resource arguments)

  acl = "private"

  versioning {
    enabled = false
  }

}

resource "aws_instance" "debian_netology" {
    ami =  "ami-06382629a9eb569e3"
    instance_type = var.cur_instance_type[terraform.workspace]
    count = local.instance_count_map[terraform.workspace]

    provisioner "local-exec" {
        command = "echo ${self.private_ip} >> private_ips.txt"
    }

    lifecycle {
      create_before_destroy = true
      prevent_destroy = false
      ignore_changes = [tags]
    }
}

resource "aws_instance" "web_netology" {
   for_each = local.instances 
      ami = each.value
      instance_type = each.key
}

