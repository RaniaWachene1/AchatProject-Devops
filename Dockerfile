FROM adoptopenjdk/openjdk17:alpine-slim

# Expose the application port
EXPOSE 8082

# Copy the JAR file from the target directory (pass as an argument)
ARG JAR_FILE
COPY ${JAR_FILE} app.jar

# Set the entry point to run the application
ENTRYPOINT ["java", "-jar", "/app.jar"]
