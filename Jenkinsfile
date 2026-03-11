pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-2'
        ECR_REPO   = 'insurance-api'
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        K8S_NAMESPACE = 'insurance-app'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/kofisefa/insurance-cloud-platform.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform/environments/dev') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('kubernetes/insurance-app') {
                    sh "docker build -t ${ECR_REPO}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push to ECR') {
            steps {
                withAWS(region: AWS_REGION, credentials: 'aws-jenkins-creds') {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.${AWS_REGION}.amazonaws.com"
                    sh "docker tag ${ECR_REPO}:${IMAGE_TAG} <aws_account_id>.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
                    sh "docker push <aws_account_id>.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withAWS(region: AWS_REGION, credentials: 'aws-jenkins-creds') {
                    sh "aws eks update-kubeconfig --region ${AWS_REGION} --name insurance-dev-eks"
                    sh "kubectl set image deployment/insurance-api insurance-api=<aws_account_id>.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} -n ${K8S_NAMESPACE}"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl get pods -n ${K8S_NAMESPACE}"
                sh "kubectl get svc -n ${K8S_NAMESPACE}"
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f' // clean local Docker images
        }
        success {
            echo 'Deployment successful!'
        }
        failure {
            echo 'Deployment failed. Check logs.'
        }
    }
}