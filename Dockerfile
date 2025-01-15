# Stage 1: Truststore Stage (Optional, you can customize it further
FROM eclipse-temurin:19-jdk-alpine as truststore

# Stage 2: Production Stage
FROM eclipse-temurin:21-jre-alpine

# Set the maintainer label
LABEL maintainer="it-devops@rakbank.ae"

# Update the package list and install the OpenJDK package
RUN apk update && apk add --no-cache openjdk21-jdk

# Set the working directory to /usr/app
WORKDIR /usr/app

# Copy the JAR file into the image using a wildcard pattern to match the generated JAR
COPY target/digital-asset-*-SNAPSHOT.jar /usr/app/app.jar

# Extract the JAR file, move the dependency JAR, and remove unnecessary directories
RUN jar xvf app.jar && \
    mkdir -p /app/libs && \
    mv BOOT-INF/lib/aws-opentelemetry-agent-1.32.1.jar /app/libs/ && \
    rm -rf BOOT-INF/ META-INF/ org/

# Command to run the Spring Boot application
ENTRYPOINT ["sh", "-c", "java -jar /usr/app/app.jar"]

# Default command if no arguments provided
CMD ["java", "-jar", "/usr/app/app.jar"]
