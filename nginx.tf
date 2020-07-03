

resource "aws_subnet" "default" {

  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "10.0.1.0/24"

  #map_public_ip_on_launch = true

}


# A security group for the nginx so it is accessible via the web

resource "aws_security_group" "ngi-group" {

  name = "nginx_connect"

  description = "nginx connection over the internet "

  vpc_id = "${aws_vpc.default.id}"

  #  Access via the internet

  ingress {

    from_port = 80

    to_port = 80

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }


  # Access via SSH

  ingress {

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = ["0.0.0.0/0"]

  }

  # outbound internet access

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}



#resource "aws_key_pair" "tkay1" {

#  key_name = "tkay"

#  public_key = file(var.path_to_public_key)

#}


resource "aws_instance" "web" {

  instance_type = "t2.micro"

  ami = "ami-0ea3405d2d2522162"
 
  key_name = "tkay"

  # Our Security group to allow HTTP and SSH access

  vpc_security_group_ids = ["${aws_security_group.ngi-group.id}"]

  subnet_id = "${aws_subnet.default.id}" 

}



resource "aws_eip" "main" {
    instance = aws_instance.web.id
    vpc = true
}

resource "null_resource" "connect_ssh" {

    connection {

    # The default username for our AMI

    user = "ec2-user"

    host = aws_eip.main.public_ip

    private_key = file(var.path_to_private_key)

    # The connection will use the local SSH agent for authentication.

  }

   provisioner "file" {
    source      = "${path.cwd}/temp_ng.tpl"
    destination = "sudo /etc/yum.repos.d/nginx.repo"
  }

  provisioner "remote-exec" {

    inline = [

      "sudo yum update -y",

      "sudo yum install nginx -y",

      "sudo service nginx start",
    ]

  }
  depends_on = ["aws_eip.main"]
}
