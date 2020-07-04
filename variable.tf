variable "path_to_public_key" {

  default = "~/devops/terrapro/project2/tkay.pub"

}



variable "path_to_private_key" {

  default = "~/devops/terrapro/project2/tkay"

}





variable "aws_region" {

  description = "AWS region to launch servers."

  default = "eu-west-1"

}

variable "amis" {
  type = "map"
  default = {
    "eu-west-1" = "ami-0ea3405d2d2522162"
    "us-east-1" = "ami-09d95fab7fff3776c"
  }
}
