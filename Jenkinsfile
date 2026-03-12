pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        AWS_ACCOUNT_ID = '920310277638'   // <-- Replace with your AWS account ID
        IMAGE_TAG = "v1-${env.BUILD_NUMBER}"
        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/insurance-api"
        KUBECONFIG = '/var/jenkins_home/.kube/config'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/kofisefa/insurance-cloud-platform.git', branch: 'main', credentialsId: 'github_pat'
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
                    sh """
                    # Login to AWS ECR
                    aws ecr get-login-password --region ${AWS_REGION} | \
                        docker login --username AWS --password-stdin ${ECR_REPO}

                    # Build Docker image
                    docker build -t ${ECR_REPO}:${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Push to ECR') {
            steps {
                sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                dir('kubernetes/insurance-app') {
                    // Update the deployment YAML with the new image tag
                    sh "sed -i 's|image: .*|image: ${ECR_REPO}:${IMAGE_TAG}|' insurance-deployment.yaml"

                    // Apply the deployment to EKS
                    sh "kubectl apply -f insurance-deployment.yaml"
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl rollout status deployment/insurance-api"
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Deployment failed. Check logs.'
        }
    }
}