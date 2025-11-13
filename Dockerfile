# Use an official Maven image to build the project
FROM maven:3.9.9-eclipse-temurin-17 AS builder

# Set the working directory
WORKDIR /app

# Copy pom.xml and download dependencies first (for caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the rest of the source code
COPY src ./src

# Build the application (e.g., jar file)
RUN mvn clean package -DskipTests

# ---- Runtime stage ----
FROM eclipse-temurin:17-jdk-alpine

# Set working directory in the container
WORKDIR /app

# Copy the jar from the builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose the application port (change if your app runs on another port)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
