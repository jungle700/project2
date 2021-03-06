# Specify the provider and access details

provider "aws" {

  region = var.aws_region

}

resource "aws_vpc" "default" {

  cidr_block = "10.0.0.0/16"

}


resource "aws_internet_gateway" "default" {

  vpc_id = aws_vpc.default.id

}


resource "aws_route" "internet_access" {

  route_table_id = "${aws_vpc.default.main_route_table_id}"

  destination_cidr_block = "0.0.0.0/0"

  gateway_id = "${aws_internet_gateway.default.id}"

}



resource "aws_subnet" "default2" {

  vpc_id = "${aws_vpc.default.id}"

  cidr_block = "10.0.2.0/24"

  #map_public_ip_on_launch = true

}


# A security group for the nginx so it is accessible via the web

resource "aws_security_group" "jenkins-group" {

  name = "jenkins_connect"

  description = "jenkins connection over the internet "

  vpc_id = "${aws_vpc.default.id}"

  #  Access via the internet

  ingress {

    from_port = 8080

    to_port = 8080

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








resource "aws_key_pair" "tkay" {

key_name = "tkay"

public_key = file(var.path_to_public_key)

}

data "template_file" "myuserdata2" {

  template = file("${path.cwd}/temp_jen.tpl")
  

  }

resource "aws_instance" "web2" {

  instance_type = "t2.micro"

  ami = var.amis[var.aws_region]
 
  key_name = "tkay"

  # Our Security group to allow HTTP and SSH access

  vpc_security_group_ids = ["${aws_security_group.jenkins-group.id}"]

  subnet_id = "${aws_subnet.default2.id}" 

  user_data = data.template_file.myuserdata2.template

  tags = {

    Name = "Jenkins_Server"

  }

}





resource "aws_eip" "main2" {
     instance = aws_instance.web2.id
     vpc = true
   }


terraform {
  backend "s3" {
    bucket = "my-tf-dev001"
    key    = "dev/terraform.tfstate"
    region = "eu-west-1"
  }
}

