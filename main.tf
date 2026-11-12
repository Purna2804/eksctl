resource "aws_instance" "workstation" {
    ami                     = local.ami_id 
    instance_type           = "t3.micro"
    vpc_security_group_ids  = [aws_security_group.allow_workstation.id]
    user_data = templatefile("${path}/workstation.sh.tftpl", {
        aws_access_key = var.aws_access_key 
        aws_secret_key = var.aws_secret_key 
    })

    root_block_device {
        volume_size = 50 
        volume_type = "gp3"
        tags = merge(
            local.common_tags, 
            {
                Name = "${var.project}-${var.environment}-workstation"
            }
        )
    }

    tags = merge(
        {
            Name = "${var.project}-${var.environment}-workstation"
        },
        local.common_tags 
    )
}

resource "aws_security_group" "allow_workstation" {
    name        = "allow-workstation"
    description = "Allow TLS inbound and all outbound traffic"

    egress {
        from_port           = 0 
        to_port             = 0 
        protocol            = "-1"
        cidr_blocks         = ["0.0.0.0/0"]
        ipv6_cidr_blocks    = ["::/0"]
    }

    ingress {
        from_port   = 22 
        to_port     = 22 
        protocol    = "tcp"
        cidr_blocks = ["${chomp("data.http.my_public_ip".response_body)}/32"]
    }

    tags = merge(
        local.common_tags, 
        {
            Name = "${var.project}-${var.environment}-allow-workstation"
        }
    )

    lifecycle {
        create_before_destroy = true
    }
}

resource "terraform_data" "asas" {
    input = {
        host        = aws_instance.workstation.public_ip 
        password    = var.ssh_password 
    }

    provisioner "remote-exec" {
        when = destroy 
        inline = [
            "ekstcl delete cluster -f /home/ec2-user/eksctl/eksctl.yaml --wait"
        ]
        connection {
            type        = "ssh"
            user        = "ec2-user"
            password    = self.input.password
            host        = self.input.host 
        }
    }
}
