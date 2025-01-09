The error you're encountering, `authentication failed for https://rakartifactory.jfrog.io/artifactory/rakbank-artifactory-maven-dev/`, suggests that Maven is unable to authenticate with the Artifactory repository. Here's a breakdown of how you can resolve the issue:

### 1. **Ensure Proper Authentication in `settings.xml`**
   Your Maven setup requires proper authentication to access Artifactory. The credentials (username and password) for your repository need to be provided in the Maven `settings.xml` file.

   - **Locate the `settings.xml` file**: It can usually be found in the following locations:
     - `~/.m2/settings.xml` (user-specific)
     - `Maven installation directory/conf/settings.xml` (system-wide)
   
   - **Add credentials in `settings.xml`**: If not already present, you need to add your Artifactory credentials. Here's an example of what to include:

     ```xml
     <servers>
       <server>
         <id>rakbank-artifactory-maven-dev</id>
         <username>${env.ARTIFACTORY_USERNAME}</username>
         <password>${env.ARTIFACTORY_PASSWORD}</password>
       </server>
     </servers>
     ```

     Replace `${env.ARTIFACTORY_USERNAME}` and `${env.ARTIFACTORY_PASSWORD}` with your actual credentials or reference environment variables if you're using them in a CI/CD pipeline.

### 2. **Using GitHub Secrets for Authentication**
   Since you are using GitHub Actions, it's recommended to store your Artifactory credentials as GitHub secrets and reference them in the GitHub Actions workflow.

   - **Set up GitHub secrets**:
     Go to your GitHub repository's settings > Secrets > New repository secret, and add `ARTIFACTORY_USERNAME` and `ARTIFACTORY_PASSWORD`.

   - **Reference secrets in the GitHub Actions workflow**:
     In your workflow, pass these secrets as environment variables or inputs:

     ```yaml
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
         ARTIFACTORY_USERNAME: ${{ secrets.ARTIFACTORY_USERNAME }}
         ARTIFACTORY_PASSWORD: ${{ secrets.ARTIFACTORY_PASSWORD }}
     ```

### 3. **Verify the Repository URL in `pom.xml`**
   Ensure the repository URL in your `pom.xml` is correctly defined:

   ```xml
   <repositories>
     <repository>
       <id>rakbank-artifactory-maven-dev</id>
       <name>rakbank-artifactory-maven-dev</name>
       <url>https://rakartifactory.jfrog.io/artifactory/rakbank-artifactory-maven-dev/</url>
     </repository>
   </repositories>
   ```

   If the URL or credentials have changed, update them accordingly.

### 4. **Check Artifactory Permissions**
   - Make sure that the credentials you're using have access to the repository and the specific artifact (`otel-observability-core:jar:1.0.0-SNAPSHOT`). If you're unsure about the permissions, check with the Artifactory administrator.

### 5. **Run Maven with Debugging Enabled**
   If the issue persists, you can run Maven with debug logging to get more detailed information:

   ```bash
   mvn clean install -X
   ```

   This will provide more context and might help in diagnosing the exact cause of the failure.

### 6. **Consider Using a Different Repository**
   If the issue is specific to Artifactory and you're still encountering authentication failures, consider verifying if the repository is accessible and working correctly by trying to access it directly via a browser or using `curl` with the same credentials.

By ensuring that the credentials are correctly set, the repository URL is valid, and the necessary permissions are in place, this should resolve the authentication issue. Let me know if you need more assistance!
