pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        AWS_ACCOUNT_ID = '920310277638'        // <-- Replace with your AWS Account ID
        ECR_REPO = 'insurance-api'
        IMAGE_TAG = "v${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                git(
                    url: 'https://github.com/kofisefa/insurance-cloud-platform.git',
                    branch: 'main',
                    credentialsId: 'github_pat'
                )
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

        stage('Prepare Deployment') {
            steps {
                dir('kubernetes/insurance-app') {
                    sh """
                    sed -i "s|image: nginx|image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}|g" insurance-deployment.yaml
                    """
                }
            }
        }

        stage('Push to ECR') {
            steps {
                sh """
                aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                docker tag ${ECR_REPO}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
                docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                aws eks update-kubeconfig --region ${AWS_REGION} --name insurance-dev-eks
                kubectl apply -f kubernetes/insurance-app/
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh 'kubectl rollout status deployment/insurance-api'
                sh 'kubectl get pods -o wide'
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
        }
        success {
            echo 'Deployment succeeded!'
        }
        failure {
            echo 'Deployment failed. Check logs.'
        }
    }
}