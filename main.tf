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
