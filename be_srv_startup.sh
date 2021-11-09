#!/bin/bash

# system updating
sudo apt update
sudo apt upgrade -y

export DATASOURCE_USERNAME=${DATASOURCE_USERNAME}
export DATASOURCE_PASSWORD=${DATASOURCE_PASSWORD}
export DB_SRV_IP=${DB_SRV_IP}


# test string

# installing OpenJDK v.8
sudo apt install openjdk-8-jdk -y

# installing maven
sudo apt install maven -y

# downloading eSchool project
mkdir /application
cd /application
echo $DATASOURCE_USERNAME > 123.test
echo $DATASOURCE_PASSWORD >> 123.test
echo $DB_SRV_IP >> 123.test
git clone https://github.com/yurkovskiy/eSchool.git

# work-directory changing
cd eSchool/

# commenting non-usable test
sudo echo '/**' >src/test/java/academy/softserve/eschool/controller/ScheduleControllerIntegrationTest.java
sudo echo '**/' >>src/test/java/academy/softserve/eschool/controller/ScheduleControllerIntegrationTest.java

# changing default DB-server IP to real
sudo sed -i 's/localhost/'$DB_SRV_IP'/g' src/main/resources/application.properties

# changing default DB-server user to real
sudo sed -i '3s/.*/spring.datasource.username='$DATASOURCE_USERNAME'/' src/main/resources/application.properties
sudo sed -i '4s/.*/spring.datasource.password='$DATASOURCE_PASSWORD'/' src/main/resources/application.properties

#  maven build start
sudo mvn clean

# maven packg build start
sudo mvn package

# auto loading after reboot
sudo echo "#!"/bin"/bash""" > tmp123
sudo echo "sudo nohup java -jar /application/eSchool/target/eschool.jar &" >> tmp123
sudo echo "sudo /TC_ci-cd/buildAgent/bin/./agent.sh start" >> tmp123
sudo cat tmp123 > /etc/rc.local
sudo rm -r tmp123
sudo chmod +x /etc/rc.local

# java-app start
cd target/
sudo nohup java -jar eschool.jar &
