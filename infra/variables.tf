variable "aws_region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "us-east-2" # edit here
}

variable "ingress_ports" {
    description = "Port rules of the Security Group"
    type        = list(number)
    default     = [22, 80, 443, 8080, 9100, 9090, 3000]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
  default     = "ansible"
}

variable "volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 10
}

variable "ssh_key_path" {
  description = "Path to the SSH private key on the Ansible control node"
  type        = string
  default     = "~/.ssh/ansible" # edit according to yours private key
}


variable "instances" {

  description = "Map of instance names to AMI IDs, SSH users, and OS family"
  
  type = map(object({
    ami       = string
    user      = string
    os_family = string
    instance_type = string
  }))

  # by deafult value to be put in the variable
  default = {
    "worker-ubuntu" = {
      ami       = "ami-07062e2a343acc423" # Ubuntu Server 24.04 LTS
      user      = "ubuntu"
      os_family = "ubuntu"
      instance_type = "t3.micro"
    }
    "worker-amazon" = {
      ami       = "ami-0a1b6a02658659c2a" # Amazon Linux 2023 — update for your region
      user      = "ec2-user"
      os_family = "amazon"
      instance_type = "t3.micro"
    }
  }
}
