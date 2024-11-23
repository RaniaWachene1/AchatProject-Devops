FROM openjdk:17-jdk-alpine

# Expose the application port
EXPOSE 8082

# Specify build-time argument for the JAR file
ARG JAR_FILE

# Copy the JAR file to the container
COPY ${JAR_FILE} app.jar

# Set the entry point to run the application
ENTRYPOINT ["java", "-jar", "/app.jar"]
