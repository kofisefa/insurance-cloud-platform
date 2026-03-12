pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        AWS_ACCOUNT_ID = '920310277638' // <--- replace with your AWS account ID
        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/insurance-api"
        IMAGE_TAG = "v1-${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout([$class: 'GitSCM',
                          branches: [[name: 'main']],
                          userRemoteConfigs: [[url: 'https://github.com/kofisefa/insurance-cloud-platform.git', credentialsId: 'github_pat']]])
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

        stage('Login to ECR & Push Image') {
            steps {
                sh """
                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin ${ECR_REPO}
                    docker push ${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                dir('kubernetes/insurance-app') {
                    // Create namespace if missing
                    sh 'kubectl create namespace insurance-app --dry-run=client -o yaml | kubectl apply -f -'

                    // Update deployment image
                    sh "sed -i s|image: .*|image: ${ECR_REPO}:${IMAGE_TAG}| insurance-deployment.yaml"

                    // Apply deployment
                    sh 'kubectl apply -f insurance-deployment.yaml'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                dir('kubernetes/insurance-app') {
                    sh 'kubectl get pods -n insurance-app'
                    sh 'kubectl get svc -n insurance-app'
                }
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
            echo 'Pipeline finished.'
        }
    }
}