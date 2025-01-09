name: CICD Orchestrator
## This pipeline perform continous integration on any new commit and deploy the releases into environments

permissions:
  id-token: write
  contents: write
  security-events: write
  actions: read
  pull-requests: write

on:
  workflow_dispatch:
  # push:
  #   branches:
  #     # - '**'
  # pull_request:
  #   branches:
  #     - 'release*/*'

jobs:
  Identify_Environment:
    name: "Identifying the environment"
    runs-on: ubuntu-latest
    outputs:
      target_env: ${{ steps.set_env.outputs.env }}
    steps:
      - name: Determine Target Environment
        id: set_env
        run: |
            echo "env=dev"  >> $GITHUB_OUTPUT  
        shell: bash 

  ci:
    name: "Continuous Integration"
    needs: Identify_Environment
    uses: rakbank-internal/enterprise-reusable-workflows/.github/workflows/multijob-maven-continous-integration.yml@feature/jfrog-app-publish
    with:
      AWS_REGION : ${{ vars.AWS_REGION }}
      AWS_IAM_ROLE : ${{ vars.AWS_IAM_ROLE }}
      SONAR_PROJECT_KEY : ${{ vars.SONAR_PROJECT_KEY }}
      JAVA_VERSION_APP : ${{ vars.JAVA_VERSION_APP }}
      JAVA_VERSION_SONAR : ${{ vars.JAVA_VERSION_SONAR }}
      ENVIRONMENT: ${{ needs.Identify_Environment.outputs.target_env }}
      PUBLISH_IMAGE: ${{ vars.PUBLISH_IMAGE }}
    secrets:
      AWS_ACCOUNT_ID : ${{ secrets.AWS_ACCOUNT_ID }}
      AWS_ECR : ${{ secrets.AWS_ECR }}
      DEVOPS_WORKFLOW_TOKEN: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}
      SONAR_TOKEN:  ${{ secrets.SONAR_TOKEN }}
      SONAR_HOST_URL:  ${{ secrets.SONAR_HOST_URL }}
      JFROG_USERNAME:  ${{ secrets.JFROG_USERNAME }}
      JFROG_ARTIFACTORY_ACCESS_TOKEN:  ${{ secrets.JFROG_ARTIFACTORY_ACCESS_TOKEN }}
      SONAR_ORGANIZATION_KEY:  ${{ secrets.SONAR_ORGANIZATION_KEY }}


  deploy:
    name: "Deploy application"
    needs: [ ci, Identify_Environment ]
    uses: rakbank-internal/enterprise-reusable-workflows/.github/workflows/helm-release-orchastrator.yml@feature/jfrog-app-publish
    with:
      AWS_REGION : ${{ vars.AWS_REGION }}
      AWS_IAM_ROLE : ${{ vars.AWS_IAM_ROLE }}
      K8S_MANIFEST_REPO : ${{ vars.K8S_MANIFEST_REPO }}
      K8S_VALUES_FILE : ${{ vars.K8S_VALUES_FILE }}
      HELM_CHART_REPO: ${{ vars.HELM_CHART_REPO }}
      RELEASE_NAME: ${{ vars.RELEASE_NAME }}
      IMAGE_TAG: ${{ needs.ci.outputs.IMAGE_TAG }}
    secrets:
      AWS_ACCOUNT_ID : ${{ secrets.AWS_ACCOUNT_ID }}
      AWS_K8S_CLUSTER : ${{ secrets.AWS_K8S_CLUSTER }}
      AWS_K8S_NAME_SPACE: ${{ secrets.AWS_K8S_NAME_SPACE }}
      DEVOPS_WORKFLOW_TOKEN: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}
      

Prepare all required actions
Getting action download info
Download action repository 'actions/cache@v4' (SHA:1bd1e32a3bdc45362d1e726936510720a7c30a57)
Download action repository 'actions/setup-java@v4' (SHA:7a6d8a8234af8eb26422e24e3006232cccaa061b)
Run ./reusable-workflows/.github/actions/maven-compile
Run actions/cache@v4
Cache not found for input keys: Linux-m2-26c86510924d577bdcd59a55471f9bd13eaa13b5f50d794f416789e774753221, Linux-m2
Run actions/setup-java@v4
Installed distributions
  Error: java-version or java-version-file input expected
