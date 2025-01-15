
#10 0.583 mv: cannot stat 'BOOT-INF/lib/aws-opentelemetry-agent-1.32.1.jar': No such file or directory
#10 ERROR: process "/bin/sh -c jar xvf app.jar &&     mkdir -p /app/libs &&     mv BOOT-INF/lib/aws-opentelemetry-agent-1.32.1.jar /app/libs/ &&     rm -rf BOOT-INF/ META-INF/ org/" did not complete successfully: exit code: 1
------
 > [stage-1 5/5] RUN jar xvf app.jar &&     mkdir -p /app/libs &&     mv BOOT-INF/lib/aws-opentelemetry-agent-1.32.1.jar /app/libs/ &&     rm -rf BOOT-INF/ META-INF/ org/:
0.560 extracted: BOOT-INF/lib/spring-jdbc-6.1.11.jar
0.561 extracted: BOOT-INF/lib/jakarta.xml.bind-api-4.0.2.jar
0.561 extracted: BOOT-INF/lib/jakarta.activation-api-2.1.3.jar
0.565 extracted: BOOT-INF/lib/spring-core-6.1.11.jar
0.566 extracted: BOOT-INF/lib/spring-jcl-6.1.11.jar
0.570 extracted: BOOT-INF/lib/h2-2.2.224.jar
0.570 extracted: BOOT-INF/lib/spring-boot-jarmode-tools-3.3.2.jar
0.570  inflated: BOOT-INF/classpath.idx
0.571  inflated: BOOT-INF/layers.idx
0.583 mv: cannot stat 'BOOT-INF/lib/aws-opentelemetry-agent-1.32.1.jar': No such file or directory
------
Dockerfile:15
--------------------
  14 |     
  15 | >>> RUN jar xvf app.jar && \
  16 | >>>     mkdir -p /app/libs && \
  17 | >>>     mv BOOT-INF/lib/aws-opentelemetry-agent-1.32.1.jar /app/libs/ && \
  18 | >>>     rm -rf BOOT-INF/ META-INF/ org/
  19 |     
--------------------
ERROR: failed to solve: process "/bin/sh -c jar xvf app.jar &&     mkdir -p /app/libs &&     mv BOOT-INF/lib/aws-opentelemetry-agent-1.32.1.jar /app/libs/ &&     rm -rf BOOT-INF/ META-INF/ org/" did not complete successfully: exit code: 1
Error: Process completed with exit code 1.

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
