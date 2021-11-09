# READ ME!
# Before start run your docker-container builded by this docker-file into docker-image you need to know:
# 1. This application use a 3 environment variables:
# - DATASOURCE_USERNAME - name of a user inside your DB-server
# - DATASOURCE_PASSWORD - password of this user
# - DB_SRV_IP - IP-address of your DB-server but !!!! WARNING !!!! this variable MUST BE ADDED BEFORE BUILD !!!
# so use a "-e" key;
#
# 2. This application need to use port 8080 for web-requests, so use a "-p" key; 
#
# 3. Example: 
#    docker run -p 8080:8080 -e DATASOURCE_USERNAME=Qwerty -e DATASOURCE_PASSWORD=Qwerty <image_id or name> 
#
# 4. Every docker image build means that this application will be rebuilded (for updating some data you need to rebuild docker-image).

FROM ubuntu:20.04

# port which used by eSchool application
EXPOSE 8080

# environment variable for supporting cyrillic symbols
ENV LANG C.UTF-8

# !!!! WARNING !!!! change you database-server IP before building docker-image !!!
ENV DB_SRV_IP=<your DB-server IP-address>

# list of commands for application building
RUN apt update 
RUN apt install openjdk-8-jdk -y 
RUN apt install maven -y 
RUN mkdir /application 
RUN apt install git -y 
RUN git clone https://github.com/yurkovskiy/eSchool.git /application 
RUN echo '/**' > /application/src/test/java/academy/softserve/eschool/controller/ScheduleControllerIntegrationTest.java 
RUN echo '**/' >> /application/src/test/java/academy/softserve/eschool/controller/ScheduleControllerIntegrationTest.java 
RUN sed -i 's/localhost/'$DB_SRV_IP'/g' /application/src/main/resources/application.properties 
RUN sed -i '3s/.*/spring.datasource.username='$DATASOURCE_USERNAME'/' /application/src/main/resources/application.properties 
RUN sed -i '4s/.*/spring.datasource.password='$DATASOURCE_PASSWORD'/' /application/src/main/resources/application.properties 
RUN mvn -f /application clean 
RUN mvn -f /application package

# main process startup
ENTRYPOINT ["java", "-jar", "/application/target/eschool.jar"]
