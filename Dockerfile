FROM adoptopenjdk/openjdk11:jdk-11.0.11_9-alpine-slim

# Expose the application port
EXPOSE 8082

# Copy the JAR file from the target directory
COPY target/tpAchatProject-1.0.jar tpAchatProject-1.0.jar

# Set the entry point to run the application
ENTRYPOINT ["java", "-jar", "/tpAchatProject-1.0.jar"]
