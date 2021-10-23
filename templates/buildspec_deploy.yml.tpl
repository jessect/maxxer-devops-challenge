version: 0.2
phases:
  install:
    commands:
      - echo "Installing kubectl..."    
      - curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
      - chmod +x ./kubectl
      - mkdir -p $HOME/bin && mv ./kubectl $HOME/bin/kubectl && export PATH=$HOME/bin:$PATH
      - kubectl version --short --client      
      - echo "Installing helm..."    
      - curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
      - helm version
      - echo "Intalling aws cli"
      - pip install --upgrade pip
      - pip install --upgrade awscli
      - aws --version
  pre_build:
    commands:
      - echo "Updating kubeconfig..."
      - aws eks --region $AWS_DEFAULT_REGION update-kubeconfig --name $K8S_CLUSTER_NAME
      - cat /root/.kube/config
      - kubectl get all
      - IMAGE_TAG="$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | head -c 8)"
  build:
    commands:
      - echo "Deploying app..."
      - |
          if helm status -n $K8S_NAMESPACE  myapp; then
            echo "myapp release found. Upgrading..."
            helm upgrade myapp ./helm -n $K8S_NAMESPACE \
              --set image.repository="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME" \
              --set image.tag="$IMAGE_TAG" \
              --set configmap.db_host="$DB_HOST" \
              --set configmap.db_name="$DB_NAME" \
              --set configmap.db_user="$DB_USER" \
              --set configmap.db_pass="$DB_PASS"
          else
            echo "myapp release not found. Installing..."
            helm install myapp ./helm -n $K8S_NAMESPACE \
              --set image.repository="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$IMAGE_REPO_NAME" \
              --set image.tag="$IMAGE_TAG" \
              --set configmap.db_host="$DB_HOST" \
              --set configmap.db_name="$DB_NAME" \
              --set configmap.db_user="$DB_USER" \
              --set configmap.db_pass="$DB_PASS"
          fi  
  post_build:
    commands:
      - echo "post_build step"