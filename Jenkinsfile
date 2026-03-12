pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        AWS_ACCOUNT_ID = '920310277638'  // replace with your AWS account ID
        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/insurance-api"
        IMAGE_TAG = "v1-${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout SCM') {
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
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                    docker push ${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Prepare Deployment') {
            steps {
                dir('kubernetes/insurance-app') {
                    sh """
                        ls -l
                        echo ECR_REPO=${ECR_REPO} IMAGE_TAG=${IMAGE_TAG}
                        sed -i 's|image: .*|image: ${ECR_REPO}:${IMAGE_TAG}|' insurance-deployment.yaml
                        cat insurance-deployment.yaml
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    # Update kubeconfig
                    aws eks update-kubeconfig --region ${AWS_REGION} --name insurance-dev-eks

                    # Create namespace if it doesn't exist
                    kubectl get namespace insurance-app || kubectl create namespace insurance-app

                    # Apply all manifests
                    kubectl apply -f kubernetes/insurance-app/insurance-deployment.yaml
                    kubectl apply -f kubernetes/insurance-app/insurance-service.yaml
                    kubectl apply -f kubernetes/insurance-app/insurance-ingress.yaml
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                sh "kubectl get pods -n insurance-app"
                sh "kubectl get svc -n insurance-app"
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
        }
    }
}