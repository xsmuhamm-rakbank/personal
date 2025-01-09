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

Resuable workflow 

name: Maven Continous Integration

permissions:
  id-token: write #Allows the workflow to request an OpenID Connect JWT
  contents: write # Allows the workflow to push commits to the repository.
  security-events: write # Allows the workflow to create, update, and delete security events, such as code scanning alerts.
  actions: read # Allows the workflow to read metadata about GitHub Actions workflows and workflow runs.
  pull-requests: write # Allows the workflow to write dependency review to pull request. 


on:
  workflow_call:
  
    inputs:
      SONAR_PROJECT_KEY :
       required: true
       type: string
      AWS_REGION :
       type: string
      AWS_IAM_ROLE :
       # required: true
       type: string
      ENVIRONMENT:
        required: true
        type: string
      K8S_MANIFEST_REPO: 
        type: string
      K8S_MANIFEST_FILE: 
        type: string
      JAVA_VERSION_APP: 
        required: true
        type: string
      JAVA_VERSION_SONAR: 
        required: true
        type: string
      PUBLISH_APP_ARTIFACT: 
        type: string
      PUBLISH_IMAGE: 
        type: string
      DEPLOY_MANIFEST:
        type: string
      DEPLOY_HELM:
        type: string
      
    secrets:
      DEVOPS_WORKFLOW_TOKEN:
         required: true
      JFROG_USERNAME: 
        required: true
      JFROG_ARTIFACTORY_ACCESS_TOKEN: 
        required: true
      SONAR_TOKEN:
         required: true
      SONAR_HOST_URL:
         required: true
      SONAR_ORGANIZATION_KEY:
         required: true
      AWS_ACCOUNT_ID :
       required: false
      AWS_ECR :
       required: false

    outputs:
        IMAGE_TAG:
          description: "The image tag published"
          value: ${{ jobs.docker-build-publish.outputs.branch_tag }}
      

jobs:
  compile:
    name: Compile 
    runs-on: ubuntu-latest
    steps:
      - name: Checkout application code
        uses: actions/checkout@v4
          
      - name: Checkout reusable code
        uses: actions/checkout@v4
        with:
          repository: rakbank-internal/enterprise-reusable-workflows
          ref: main
          path: reusable-workflows
          token: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}
          
      - name: Compile with Maven
        uses: ./reusable-workflows/.github/actions/maven-compile
        with:
          JAVA_VERSION_APP: ${{ inputs.JAVA_VERSION_APP }}
          JFROG_USERNAME: ${{ secrets.JFROG_USERNAME }}
          JFROG_ARTIFACTORY_ACCESS_TOKEN: ${{ secrets.JFROG_ARTIFACTORY_ACCESS_TOKEN }}

          
  test:
    name: Unit Test
    needs: compile
    runs-on: ubuntu-latest
    steps:
      - name: Checkout application code
        uses: actions/checkout@v4
        with:
          ref: ${{ github.head_ref }}
          
      - name: Checkout reusable code
        uses: actions/checkout@v4
        with:
          repository: rakbank-internal/enterprise-reusable-workflows
          ref: main
          path: reusable-workflows
          token: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}
          
      - name: Unit Test with Maven
        uses: ./reusable-workflows/.github/actions/maven-test
        with:
          JAVA_VERSION_APP: ${{ inputs.JAVA_VERSION_APP }}
          JFROG_USERNAME: ${{ secrets.JFROG_USERNAME }}
          JFROG_ARTIFACTORY_ACCESS_TOKEN: ${{ secrets.JFROG_ARTIFACTORY_ACCESS_TOKEN }}
    

  sonar:
    name: Code Quality Analysis
    needs: test
    runs-on: ubuntu-latest
    outputs:     
      target_env: ${{ steps.set_branch_name.outputs.branch }} 
    steps:
          
      - name: Checkout application code
        uses: actions/checkout@v4
    
      - name: Checkout reusable code
        uses: actions/checkout@v4
        with:
          repository: rakbank-internal/enterprise-reusable-workflows
          ref: main
          path: reusable-workflows
          token: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}

      - name: Determine Branch Name
        id: set_branch_name
        run: |
          if [[ $GITHUB_EVENT_NAME == "pull_request" ]]; then
            branch_name=${GITHUB_HEAD_REF}
          else
            branch_name=${GITHUB_REF#refs/heads/}
          fi
          echo "branch=$branch_name"  >> $GITHUB_OUTPUT
          echo "Current branch: $branch_name"
        shell: bash  
          
      - name: SonarCloud Analysis
        uses: ./reusable-workflows/.github/actions/maven-sonar
        with:
          SONAR_PROJECT_KEY: ${{ inputs.SONAR_PROJECT_KEY }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ secrets.SONAR_HOST_URL }}
          SONAR_ORGANIZATION_KEY: ${{ secrets.SONAR_ORGANIZATION_KEY }}
          BRANCH_NAME: ${{ steps.set_branch_name.outputs.branch }}
          JAVA_VERSION_SONAR: ${{ inputs.JAVA_VERSION_SONAR }}
          JFROG_USERNAME: ${{ secrets.JFROG_USERNAME }}
          JFROG_ARTIFACTORY_ACCESS_TOKEN: ${{ secrets.JFROG_ARTIFACTORY_ACCESS_TOKEN }}
        
        
  code-ql:
    name: Secure Code Analysis
    needs: test
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout application code
        uses: actions/checkout@v4
          
      - name: Checkout reusable code
        uses: actions/checkout@v4
        with:
          repository: rakbank-internal/enterprise-reusable-workflows
          ref: main
          path: reusable-workflows
          token: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}
          
      - name: Code-QL
        uses: ./reusable-workflows/.github/actions/maven-code-ql
        with:
          JAVA_VERSION_APP: ${{ inputs.JAVA_VERSION_APP }}
          JFROG_USERNAME: ${{ secrets.JFROG_USERNAME }}
          JFROG_ARTIFACTORY_ACCESS_TOKEN: ${{ secrets.JFROG_ARTIFACTORY_ACCESS_TOKEN }}
  
          
  dependancy-review:
    name: Software Composition Analysis
    needs: test
    if: ${{ github.event_name == 'pull_request' && (github.event.pull_request.base.ref == 'develop' || github.event.pull_request.base.ref == 'main' || startsWith(github.event.pull_request.base.ref, 'release'))  }}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout application code
        uses: actions/checkout@v4
  
      - name: Checkout reusable code
        uses: actions/checkout@v4
        with:
          repository: rakbank-internal/enterprise-reusable-workflows
          ref: main
          path: reusable-workflows
          token: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}
 
      - name: Dependency Review
        uses: ./reusable-workflows/.github/actions/dependancy-review

  vulnerability-scan:
    name: Image Vulnerability Scanning 
    if: ${{ inputs.PUBLISH_IMAGE == 'true' }}
    needs: [test]
    runs-on: ubuntu-latest
    environment:
      name: ${{ inputs.ENVIRONMENT }}
    steps:
      - name: Checkout application code
        uses: actions/checkout@v4
  
      - name: Checkout reusable code
        uses: actions/checkout@v4
        with:
          repository: rakbank-internal/enterprise-reusable-workflows
          ref: main
          path: reusable-workflows
          token: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}

      - name: Build Application with Maven
        uses: ./reusable-workflows/.github/actions/maven-build
        with:
          JAVA_VERSION_APP: ${{ inputs.JAVA_VERSION_APP }}
          JFROG_USERNAME: ${{ secrets.JFROG_USERNAME }}
          JFROG_ARTIFACTORY_ACCESS_TOKEN: ${{ secrets.JFROG_ARTIFACTORY_ACCESS_TOKEN }}

      - name: Build Image with Docker
        uses: ./reusable-workflows/.github/actions/docker-build
        with:
          IMAGENAME: app-image
          IMAGETAG: ${{ github.sha }}
          AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
          AWS_ECR: ${{ secrets.AWS_ECR }}
          AWS_REGION: ${{ inputs.AWS_REGION }}
          AWS_IAM_ROLE: ${{ inputs.AWS_IAM_ROLE }}
         
      - name: Vulnarability Scanning with Trivy
        uses: ./reusable-workflows/.github/actions/trivy-scan
        with:
          IMAGENAME: app-image
          IMAGETAG: ${{ github.sha }}
          
  app-build-publish:
    if: ${{ inputs.PUBLISH_APP_ARTIFACT == 'true' }}
    name: Build & Publish jar to JFrog
    needs: [sonar, code-ql]
    runs-on: ubuntu-latest
    steps:      
      - name: Checkout application code
        uses: actions/checkout@v4
  
      - name: Checkout reusable code
        uses: actions/checkout@v4
        with:
          repository: rakbank-internal/enterprise-reusable-workflows
          ref: main
          path: reusable-workflows
          token: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}

      - name: Build Application with Maven
        uses: ./reusable-workflows/.github/actions/maven-publish-local
        with:
          JAVA_VERSION_APP: ${{ inputs.JAVA_VERSION_APP }}
          JFROG_USERNAME: ${{ secrets.JFROG_USERNAME }}
          JFROG_ARTIFACTORY_ACCESS_TOKEN: ${{ secrets.JFROG_ARTIFACTORY_ACCESS_TOKEN }}

  docker-build-publish:
    name: Build and Publish Image
    needs: [ sonar, code-ql, vulnerability-scan ]
    runs-on: ubuntu-latest
    environment:
      name: ${{ inputs.ENVIRONMENT }}
    if: ${{ github.ref == 'refs/heads/develop' || startsWith(github.ref, 'refs/heads/release') || startsWith(github.ref, 'refs/heads/hotfix') && inputs.PUBLISH_IMAGE == 'true' }}
    outputs:
      branch_tag: ${{ steps.set_branch_tag.outputs.branch_tag }}
    steps:
      - name: Checkout application code
        uses: actions/checkout@v4
  
      - name: Checkout reusable code
        uses: actions/checkout@v4
        with:
          repository: rakbank-internal/enterprise-reusable-workflows
          ref: main
          path: reusable-workflows
          token: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}


      - name: Determine Branch tag
        id: set_branch_tag
        run: |
          branch_name=${GITHUB_REF#refs/heads/}
          commit_id=$(git rev-parse --short HEAD)
          job_number=${{ github.run_number }}
          if [[ $branch_name == release*/* || $branch_name == hotfix*/*  ]]; then
            branch_tag=${branch_name//\//} 
            branch_tag="${branch_tag}-${commit_id}-${job_number}"
          else
              branch_tag="${branch_name}-${commit_id}-${job_number}"
          fi
          echo "branch_tag=$branch_tag"  >> $GITHUB_OUTPUT
          echo "Current branch tag: $branch_tag"      
        shell: bash  
      
      - name: Build Application with Maven
        uses: ./reusable-workflows/.github/actions/maven-build
        with:
          JAVA_VERSION_APP: ${{ inputs.JAVA_VERSION_APP }}
          JFROG_USERNAME: ${{ secrets.JFROG_USERNAME }}
          JFROG_ARTIFACTORY_ACCESS_TOKEN: ${{ secrets.JFROG_ARTIFACTORY_ACCESS_TOKEN }}

      - name: Build Image with Docker
        uses: ./reusable-workflows/.github/actions/docker-build
        with:
          IMAGENAME: ${{ secrets.AWS_ECR }}
          IMAGETAG: ${{ steps.set_branch_tag.outputs.branch_tag }}
          AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
          AWS_ECR: ${{ secrets.AWS_ECR }}
          AWS_REGION: ${{ inputs.AWS_REGION }}
          AWS_IAM_ROLE: ${{ inputs.AWS_IAM_ROLE }}
        
      - name: Publish Image to ECR
        uses: ./reusable-workflows/.github/actions/docker-publish
        with:
          AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
          AWS_ECR: ${{ secrets.AWS_ECR }}
          AWS_REGION: ${{ inputs.AWS_REGION }}
          AWS_IAM_ROLE: ${{ inputs.AWS_IAM_ROLE }}
          BRANCH_TAG: ${{ steps.set_branch_tag.outputs.branch_tag }}

  Update-K8s-manifest:
    name: Update K8S Manifest
    needs: docker-build-publish
    runs-on: ubuntu-latest
    if: ${{ inputs.DEPLOY_MANIFEST == 'true' }}
    environment:
      name: ${{ inputs.ENVIRONMENT }}
    steps:

      - name: Checkout reusable code
        uses: actions/checkout@v4
        with:
          repository: rakbank-internal/enterprise-reusable-workflows
          ref: main
          path: reusable-workflows
          token: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}
          
      - name: Update K8S Manifest
        uses: ./reusable-workflows/.github/actions/K8s-manifest
        with:
          BRANCH_TAG: ${{ needs.docker-build-publish.outputs.branch_tag }}
          AWS_ACCOUNT_ID: ${{ secrets.AWS_ACCOUNT_ID }}
          AWS_ECR: ${{ secrets.AWS_ECR }}
          AWS_REGION: ${{ inputs.AWS_REGION }}
          K8S_MANIFEST_REPO: ${{ inputs.K8S_MANIFEST_REPO }}
          K8S_MANIFEST_FILE: ${{ inputs.K8S_MANIFEST_FILE }}
          ENVIRONMENT: ${{ inputs.ENVIRONMENT }}
          DEVOPS_WORKFLOW_TOKEN: ${{ secrets.DEVOPS_WORKFLOW_TOKEN }}
