# filename: templates/java-basic-webserver/Dockerfile
# Docker image for the Java Spring Boot application
# This is a multi-stage build to create a smaller final image

# Build stage - Compiles the Java application using Maven
FROM maven:3.8.4-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Run stage - Creates the final lightweight image
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Expose the port that the app runs on
EXPOSE 3000

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"] 