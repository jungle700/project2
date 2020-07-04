#!/bin/bash

 yum update -y

 amazon-linux-extras enable nginx1.12

 yum install nginx -y

 service nginx start