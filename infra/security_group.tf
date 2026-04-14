# define default VPC

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}


# Security Group resource definition

resource "aws_security_group" "mysg" {
    vpc_id = aws_default_vpc.default.id
    name = "ansible-sg"
    description = "Security group for the Ansible"
    
    # dynamic ingress rule

    dynamic "ingress" {
        for_each = var.ingress_ports
        content {
            description = "Allowed port ${ingress.value}"
            from_port   = ingress.value
            to_port     = ingress.value
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    # egress rule/outbound rules

    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
	Name = "ansible"
	}
    
}
