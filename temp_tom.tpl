 #!/bin/bash
 

 yum update -y

 yum install java-1.8.0-openjdk -y 

 yum -y install tomcat

 systemctl start tomcat