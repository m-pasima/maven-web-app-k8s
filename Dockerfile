# Use Tomcat 11 as base image
FROM tomcat:11-jdk17-temurin

# Remove default ROOT webapp
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy the WAR file to Tomcat
COPY target/tesco.war /usr/local/tomcat/webapps/ROOT.war

# Expose port
EXPOSE 8080

CMD ["catalina.sh", "run"]

