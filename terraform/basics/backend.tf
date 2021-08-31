# The block below configures Terraform to use the 'remote' backend with Terraform Cloud.
# For more information, see https://www.terraform.io/docs/backends/types/remote.html
#terraform {
#  backend "remote" {
#    organization = "example-org-bf3bb9"
#
#    workspaces {
#      name = "getting-study"
#    }
# }
#
#  required_version = ">= 0.13.0"
#}

terraform {
  backend "s3" {
    bucket = "frstudentdata"
    key    = "frstudentdata/key"
    region = "us-east-2"
    dynamodb_table = "frstudent-tf-locks"
    encrypt        = true
  }
}

