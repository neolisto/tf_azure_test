# READ ME!
# Before start run your docker-container builded by this docker-file into docker-image you need to know:
# 1. This application use a 3 environment variables:
# - DATASOURCE_USERNAME - name of a user inside your database-server
# - DATASOURCE_PASSWORD - password of this user
# - DB_SRV_IP - IP-address of your database-server but !
# !!! WARNING !!!! these variables MUST BE ADDED BEFORE BUILD !!!
# 
# 2. This application need to use port 8080 for web-requests, so use a "-p" key; 
#
# 3. Example: 
#    docker run -p 8080:8080 <image_id or name> 
#
# 4. Every docker image build means that this application will be rebuilded (for updating some data you need to rebuild docker-image).

FROM ubuntu:20.04

# port which used by eSchool application
EXPOSE 8080

# environment variable for supporting cyrillic symbols and time-zone setting
ENV LANG C.UTF-8
ENV TZ=Europe/Kiev

# !!!! WARNING !!!! change you database-server IP, username and password before building docker-image !!!
ENV DB_SRV_IP=***
ENV DATASOURCE_USERNAME=***
ENV DATASOURCE_PASSWORD=***

# list of commands for application building
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt update 
RUN apt install -y openjdk-8-jdk 
RUN apt install -y maven
RUN apt install -y git
RUN mkdir /application 
RUN git clone https://github.com/yurkovskiy/eSchool.git /application 
RUN echo '/**' > /application/src/test/java/academy/softserve/eschool/controller/ScheduleControllerIntegrationTest.java \
    echo '**/' >> /application/src/test/java/academy/softserve/eschool/controller/ScheduleControllerIntegrationTest.java 
RUN sed -i 's/localhost/'$DB_SRV_IP'/g' /application/src/main/resources/application.properties 
RUN sed -i '3s/.*/spring.datasource.username='$DATASOURCE_USERNAME'/' /application/src/main/resources/application.properties  
RUN sed -i '4s/.*/spring.datasource.password='$DATASOURCE_PASSWORD'/' /application/src/main/resources/application.properties 
RUN mvn -f /application clean 
RUN mvn -f /application package

# main process startup
ENTRYPOINT ["java", "-jar", "/application/target/eschool.jar"]
