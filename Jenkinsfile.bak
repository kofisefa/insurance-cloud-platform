pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-2"
    }

    stages {

        stage('Terraform Init') {
            steps {
                sh '''
                cd terraform/environments/dev
                terraform init
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh '''
                cd terraform/environments/dev
                terraform plan
                '''
            }
        }

        stage('Deploy Kubernetes App') {
            steps {
                sh '''
                kubectl apply -f kubernetes/insurance-app/insurance-deployment.yaml
                kubectl apply -f kubernetes/insurance-app/insurance-service.yaml
                kubectl apply -f kubernetes/insurance-app/insurance-ingress.yaml
                kubectl apply -f kubernetes/insurance-app/insurance-hpa.yaml
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                kubectl get pods -n insurance-app
                kubectl get svc -n insurance-app
                kubectl get hpa -n insurance-app
                '''
            }
        }

    }
}