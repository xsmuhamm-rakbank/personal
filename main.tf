Failed to execute goal on project digital-asset: Could not resolve dependencies for project ae.rakbank:digital-asset:jar:0.0.1-SNAPSHOT: Failed to collect dependencies at ae.rakbank:otel-observability-core:jar:1.0.0-SNAPSHOT: Failed to read artifact descriptor for ae.rakbank:otel-observability-core:jar:1.0.0-SNAPSHOT: Could not transfer artifact ae.rakbank:otel-observability-core:pom:1.0.0-SNAPSHOT from/to rakbank-artifactory-maven-dev (https://rakartifactory.jfrog.io/artifactory/rakbank-artifactory-maven-dev/): authentication failed for https://rakartifactory.jfrog.io/artifactory/rakbank-artifactory-maven-dev/ae/rakbank/otel-observability-core/1.0.0-SNAPSHOT/otel-observability-core-1.0.0-SNAPSHOT.pom, status: 401 Unauthorized -> [Help 1]
Error:  
Error:  To see the full stack trace of the errors, re-run Maven with the -e switch.
Error:  Re-run Maven using the -X switch to enable full debug logging.
Error:  
Error:  For more information about the errors and possible solutions, please read the following articles:
Error:  [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/DependencyResolutionException
Error: Process completed with exit code 1.

name: Release Pipeline Orchestrator!

permissions:
  id-token: write
  contents: write
  security-events: write
  actions: write
  pull-requests: write

on:
  workflow_dispatch:
  push:
    branches:
      # - '*'
      - 'develop'
      - 'main'
      - 'feature/*'
      - 'release*'
  pull_request:
    branches:
      - 'develop'
      - 'main'
      - 'release*'
      
  
jobs:
  Identify_Environment:
    name: "Identifying the environment"
    runs-on: ubuntu-latest
    outputs:     
      environment: ${{ steps.set_env.outputs.env }}     
    steps:
      - name: Determine Target Environment
        id: set_env
        run: |
          BRANCH_NAME="${GITHUB_REF#refs/heads/}"
          if [ "$BRANCH_NAME" == "develop" ]; then
            echo "::set-output name=env::dev"
          elif [[ "$BRANCH_NAME" =~ ^release ]]; then
            echo "::set-output name=env::uat"
          elif [[ "$BRANCH_NAME" =~ ^hotfix ]]; then
            echo "::set-output name=env::prod"
          else
            echo "::set-output name=env::dev"
          fi
        shell: bash  
  ci:
    name: "Continuous Integration"
    needs: Identify_Environment
    uses: rakbank-internal/enterprise-reusable-workflows/.github/workflows/multijob-maven-continous-integration.yml@composite
    with:
      AWS_REGION : ${{ vars.AWS_REGION }}
      IAMROLENAME : ${{ vars.IAMROLENAME }}
      K8SMANIFESTS : ${{ vars.K8SMANIFESTS }}
      APPMANIFESTNAME : ${{ vars.APPMANIFESTNAME }}
      SONAR_PROJECT_KEY : ${{ vars.SONAR_PROJECT_KEY }}
      ENVIRONMENT: ${{ needs.Identify_Environment.outputs.environment }}
    secrets:
      ACCOUNTID : ${{ secrets.ACCOUNTID }}
      ECRREPONAME : ${{ secrets.ECRREPONAME }}
      DEVOPS_WORKFLOW_TOKEN: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}
      SONAR_TOKEN:  ${{ secrets.SONAR_TOKEN }}
      SONAR_HOST_URL:  ${{ secrets.SONAR_HOST_URL }}
      SONAR_ORGANIZATION_KEY:  ${{ secrets.SONAR_ORGANIZATION_KEY }}

<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<parent>
		<groupId>org.springframework.boot</groupId>
		<artifactId>spring-boot-starter-parent</artifactId>
		<version>3.3.2</version>
		<relativePath/> <!-- lookup parent from repository -->
	</parent>
	<groupId>ae.rakbank</groupId>
	<artifactId>digital-asset</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<name>Digital Asset</name>
	<description>Digital Asset Service</description>
	<properties>
		<java.version>21</java.version>
		<springdoc-openapi-ui>2.5.0</springdoc-openapi-ui>
		<jacoco-maven-plugin.version>0.8.12</jacoco-maven-plugin.version>
		<sonar.tests>src/test/java</sonar.tests>
		<lombok.version>1.18.32</lombok.version>
		<lombok-mapstruct-binding.version>0.2.0</lombok-mapstruct-binding.version>
		<org.mapstruct.version>1.5.5.Final</org.mapstruct.version>
		<otel-observability-core.version>1.0.0-SNAPSHOT</otel-observability-core.version>
		<awspring.cloud.version>2.4.4</awspring.cloud.version>
		<shedlock.version>5.13.0</shedlock.version>
	</properties>
	<dependencies>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-actuator</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-cache</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-jpa</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-validation</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>
		<dependency>
			<groupId>org.liquibase</groupId>
			<artifactId>liquibase-core</artifactId>
		</dependency>

		<dependency>
			<groupId>org.postgresql</groupId>
			<artifactId>postgresql</artifactId>
			<scope>runtime</scope>
		</dependency>
		<dependency>
			<groupId>org.springdoc</groupId>
			<artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
			<version>${springdoc-openapi-ui}</version>
		</dependency>
		<dependency>
			<groupId>ae.rakbank</groupId>
			<artifactId>otel-observability-core</artifactId>
			<version>${otel-observability-core.version}</version>
		</dependency>
		<dependency>
			<groupId>org.mapstruct</groupId>
			<artifactId>mapstruct</artifactId>
			<version>${org.mapstruct.version}</version>
		</dependency>
		<dependency>
			<groupId>io.awspring.cloud</groupId>
			<artifactId>spring-cloud-starter-aws-secrets-manager-config</artifactId>
			<version>${awspring.cloud.version}</version>
		</dependency>
		<dependency>
			<groupId>net.javacrumbs.shedlock</groupId>
			<artifactId>shedlock-spring</artifactId>
			<version>${shedlock.version}</version>
		</dependency>
		<dependency>
			<groupId>net.javacrumbs.shedlock</groupId>
			<artifactId>shedlock-provider-jdbc-template</artifactId>
			<version>${shedlock.version}</version>
		</dependency>
		<dependency>
			<groupId>org.projectlombok</groupId>
			<artifactId>lombok</artifactId>
			<optional>true</optional>
		</dependency>
		<!--Test-->
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
			<scope>test</scope>
		</dependency>
		<dependency>
			<groupId>com.h2database</groupId>
			<artifactId>h2</artifactId>
			<scope>runtime</scope>
    	</dependency>
	</dependencies>
	<repositories>
		<repository>
			<id>rakbank-artifactory-maven-dev</id>
			<name>rakbank-artifactory-maven-dev</name>
			<url>https://rakartifactory.jfrog.io/artifactory/rakbank-artifactory-maven-dev/</url>
		</repository>
	</repositories>
	<build>
		<plugins>
			<plugin>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-maven-plugin</artifactId>
				<configuration>
					<excludes>
						<exclude>
							<groupId>org.projectlombok</groupId>
							<artifactId>lombok</artifactId>
						</exclude>
					</excludes>
				</configuration>
			</plugin>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-compiler-plugin</artifactId>
				<configuration>
					<source>${java.version}</source>
					<target>${java.version}</target>
					<annotationProcessorPaths>
						<path>
							<groupId>org.projectlombok</groupId>
							<artifactId>lombok</artifactId>
							<version>${lombok.version}</version>
						</path>
						<path>
							<groupId>org.mapstruct</groupId>
							<artifactId>mapstruct-processor</artifactId>
							<version>${org.mapstruct.version}</version>
						</path>
						<path>
							<groupId>org.projectlombok</groupId>
							<artifactId>lombok-mapstruct-binding</artifactId>
							<version>${lombok-mapstruct-binding.version}</version>
						</path>
					</annotationProcessorPaths>
				</configuration>
			</plugin>
			<plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>${jacoco-maven-plugin.version}</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>prepare-package</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>jacoco-check</id>
                        <goals>
                            <goal>check</goal>
                        </goals>
                        <configuration>
                            <rules>
                                <rule>
                                    <element>PACKAGE</element>
                                    <limits>
                                        <limit>
                                            <counter>LINE</counter>
                                            <value>COVEREDRATIO</value>
                                            <minimum>0.90</minimum>
                                        </limit>
                                        <limit>
                                            <counter>BRANCH</counter>
                                            <value>COVEREDRATIO</value>
                                            <minimum>0.80</minimum>
                                        </limit>
                                    </limits>
                                </rule>
                            </rules>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
		</plugins>
	</build>

</project>
