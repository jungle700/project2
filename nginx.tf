

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


data "template_file" "myuserdata" {

  template = file("${path.cwd}/temp_ngi.tpl")

  }


resource "aws_instance" "web" {

  instance_type = "t2.micro"

  ami = var.amis[var.aws_region]
 
  key_name = "tkay"

  # Our Security group to allow HTTP and SSH access

  vpc_security_group_ids = ["${aws_security_group.ngi-group.id}"]

  subnet_id = "${aws_subnet.default.id}" 

  user_data = data.template_file.myuserdata.template

  tags = {

    Name = "Nginx_Server"

  }

}



resource "aws_eip" "main" {
    instance = aws_instance.web.id
    vpc = true
}

