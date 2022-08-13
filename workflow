name: Deployment to ECR by git
on:
  push:
    branches: [ main, FixForBug ]
    
    
jobs:
  deploy:
    name: build image
    runs-on: ubuntu-latest
    
    
    steps:
    - name: checkout
      uses: actions/checkout@v2
      
    - name: Login to Amazon ECR
      id: login-ecr
      uses: aws-actions/amazon-ecr-login@v1
 
      
      env: 
        AWS_ACCESS_KEY_ID: ${{secrets.AWS_ACCESS_KEY_ID}}
        AWS_SECRET_ACCESS_KEY: ${{secrets.AWS_SECRET_ACCESS_KEY}}
        AWS_REGION: us-east-1
          
    - name: Build, Test, Tag and push image ECR
      env: 
        ECR_REGISTRY: ${{steps.login-ecr.outputs.registry}}
        ECR_REPOSITORY: webapplication-image
        IMAGE_TAG: imagev1
          
  
      run: |
        ls -ltra
        # docker image build
        docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
        docker run -d -p 8080:80 --name webapplication-image $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
        docker ps
        echo "sleep 10 secs for container to start"
        sleep 10
        curl localhost:8080
        docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
