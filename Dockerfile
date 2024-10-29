FROM openjdk:8-jdk-alpine

# Define an argument to pass the JAR file
ARG JAR_FILE=target/*.jar

# Copy the JAR file from the target directory to the container
COPY ${JAR_FILE} app.jar

# Expose the application port
EXPOSE 8082

# Set the entry point to run the application
ENTRYPOINT ["java", "-jar", "/app.jar"]
