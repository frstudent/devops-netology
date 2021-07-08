provider "aws" {
  region = "us-east-2"
}


resource "aws_instance" "source" {
    ami                                  = "ami-089fe97bc00bff7cc"
    arn                                  = "arn:aws:ec2:us-east-2:123053575934:instance/i-0d6f9cbfbc207ca72"
    associate_public_ip_address          = true
    availability_zone                    = "us-east-2c"
    instance_type                        = "t2.micro"
    cpu_core_count                       = 1
    cpu_threads_per_core                 = 1
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    monitoring                           = false
 
    ebs_block_device {
        delete_on_termination = false
        device_name           = "/dev/sdf"
        encrypted             = false
        iops                  = 0
        tags                  = {
            "mount_point" = "/home"
        }
        throughput            = 0
        volume_id             = "vol-07b7ea2d9729416dc"
        volume_size           = 4
        volume_type           = "standard"
    }

    root_block_device {
        delete_on_termination = true
        device_name           = "/dev/xvda"
        encrypted             = false
        iops                  = 100
        throughput            = 0
        volume_id             = "vol-0dc2cf910b1a6fc73"
        volume_size           = 8
        volume_type           = "gp2"
    }

}

