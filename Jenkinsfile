pipeline {
    agent any
    environment {
        AWS_REGION = 'us-east-2'
        AWS_ACCOUNT_ID = '920310277638'  // your account ID
        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/insurance-api"
        IMAGE_TAG = "v1-${BUILD_NUMBER}"
    }
    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
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
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    docker push ${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                dir('kubernetes/insurance-app') {
                    sh """
                        # Update kubeconfig
                        aws eks update-kubeconfig --region ${AWS_REGION} --name insurance-dev-eks

                        # Create namespace if missing
                        kubectl get namespace insurance-app || kubectl create namespace insurance-app

                        # Update deployment with new image
                        sed -i "s|image: .*|image: ${ECR_REPO}:${IMAGE_TAG}|" insurance-deployment.yaml

                        # Apply manifests
                        kubectl apply -f insurance-deployment.yaml
                        kubectl apply -f insurance-service.yaml
                        kubectl apply -f insurance-ingress.yaml

                        # Apply HPA
                        kubectl apply -f insurance-hpa.yaml

                        # Wait for rollout
                        # kubectl rollout status deployment/insurance-api -n insurance-app
                    """
                }
            }
        }

    }
    post {
        always {
            sh 'docker system prune -f'
        }
    }
}