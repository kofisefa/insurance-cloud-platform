# Insurance Cloud Platform

This project demonstrates a production-style AWS cloud infrastructure
built using Terraform, Kubernetes, Docker, Jenkins, Helm, and Ansible.

The platform simulates a microservices-based insurance quote processing
system deployed on Amazon EKS.

## Operational Issues & Troubleshooting

During the development of the Insurance Cloud Platform, several real-world operational issues were encountered while deploying and scaling the Kubernetes workloads on AWS EKS. These issues required debugging across multiple layers including Terraform infrastructure, Kubernetes resources, and AWS services.

Documenting these challenges demonstrates practical platform engineering and operational troubleshooting experience.

---

## Overview

This project demonstrates a full-stack cloud deployment of an Insurance API platform on AWS EKS, using Terraform for infrastructure provisioning and Kubernetes for container orchestration. It showcases cloud architecture, CI/CD pipelines, monitoring, autoscaling, and troubleshooting experience.

## Architecture Overview

The platform is deployed in a secure VPC with public subnets and exposed via an Nginx ingress controller. Worker nodes run on EC2 instances (t3.medium for this portfolio deployment). The cluster uses Prometheus and Metrics Server for observability, while Horizontal Pod Autoscalers ensure automated scaling based on CPU usage.

## Key Components:

## Architecture Overview

The Insurance Cloud Platform is deployed on **AWS EKS**, with Terraform managing the infrastructure. Kubernetes workloads run in a VPC with public subnets, and a LoadBalancer exposes services. The platform also includes monitoring and autoscaling.

**Key Components:**

- **AWS VPC** – Contains private and public subnets for EKS worker nodes and services.
- **EKS Cluster** – Managed Kubernetes cluster orchestrating containers.
- **Worker Nodes** – EC2 instances (t3.large for portfolio deployment) hosting pods.
- **Ingress Controller** – Nginx-based controller routing traffic to services.
- **Application Pods** – Insurance API deployed via Kubernetes deployments.
- **Prometheus / Metrics Server** – Monitoring cluster and application metrics.
- **Horizontal Pod Autoscaler (HPA)** – Scales pods based on CPU utilization.


## Architecture Diagram:
                     ┌───────────────────┐
                     │   Internet User    │
                     └────────┬──────────┘
                              │
                              ▼
                     ┌───────────────────┐
                     │   Nginx Ingress    │
                     └────────┬──────────┘
                              │
                ┌─────────────┴─────────────┐
                │                           │
        ┌─────────────┐             ┌─────────────┐
        │ insurance-  │             │ insurance-  │
        │ api Pod 1   │             │ api Pod 2   │
        └─────────────┘             └─────────────┘
                │                           │
                └─────────────┬─────────────┘
                              ▼
                     ┌───────────────────┐
                     │ AWS EKS Cluster    │
                     │ Worker Nodes       │
                     └────────┬──────────┘
                              │
                     ┌────────┴──────────┐
                     │ AWS VPC / Subnets  │
                     └───────────────────┘

## CI/CD Pipeline Overview

The CI/CD pipeline is implemented using Jenkins, automating infrastructure provisioning, application deployment, and monitoring setup.

## Pipeline Stages:

## CI/CD Pipeline Overview

The project uses **Jenkins** as the primary CI/CD tool to automate infrastructure provisioning and application deployment. GitHub is used as the source repository for both Terraform and Kubernetes manifests.

**Pipeline Stages:**

1. **Source Control (GitHub)**
   - Developers push changes to branches in the repository:
     - Terraform code for infrastructure
     - Kubernetes manifests for application deployments

2. **Jenkins CI**
   - Triggered automatically on push to main or dev branches.
   - Steps include:
     - Terraform `plan` and `apply` to provision or update AWS resources.
     - Linting and validation of Kubernetes YAML files.
     - Helm deploy / `kubectl apply` of manifests to EKS cluster.

3. **Deployment to AWS EKS**
   - Terraform ensures:
     - VPC, subnets, security groups, and IAM roles exist
     - EKS cluster and node groups are provisioned
   - Kubernetes manifests create:
     - Deployments and services
     - Ingress rules
     - Horizontal Pod Autoscalers
   - Monitoring stack (Prometheus, Metrics Server) is installed for observability

4. **Autoscaling & Monitoring**
   - HPA scales pods based on CPU usage.
   - Prometheus metrics monitor cluster health and application performance.
   - Alerts can be configured for operational incidents.

## Pipeline Diagram:
                 GitHub Repo
     │
     ▼
  Jenkins CI
     │
 ┌───┴─────────────────┐
 │ Terraform Apply      │
 │ Provision AWS infra  │
 └───┬─────────────────┘
     │
     ▼
 Kubernetes Deployment
     │
 ┌───┴───────────┐
 │ Deploy Pods    │
 │ Services      │
 │ Ingress       │
 └───┬───────────┘
     │
     ▼
 Autoscaling & Monitoring
(HPA + Prometheus) 

## Operational Challenges & Solutions

This section highlights real-world troubleshooting and decisions made during development:

1. Free-tier EC2 Limitations

Issue: Using t3.micro instances caused EKS node groups to fail.

Solution: Switched to t3.medium for portfolio deployment to allow enough resources for pods and monitoring stack.

2. EKS NodeGroup Creation Failures

Issue: Nodes failed to join the cluster due to insufficient IAM permissions or instance type restrictions.

Solution: Updated IAM roles with proper policies, selected supported instance types, and verified VPC/subnet configuration.

3. Cluster Autoscaling & Pending Pods

Issue: Pods stuck in Pending due to insufficient resources.

Solution: Increased node instance size, verified resource requests/limits, and applied Horizontal Pod Autoscaler.

4. Prometheus Helm Install Failures

Issue: CRD installation timed out due to EKS API latency.

Solution: Applied CRDs manually first, then installed Helm charts with --server-side apply and increased timeouts.

5. Terraform State & Orphaned Resources

Issue: Node group deletions remained in DELETE_PENDING state.

Solution: Verified AWS console, removed orphaned IAM roles, and refreshed Terraform state with terraform state rm.

# Infrastructure Scaling Challenge

While deploying the Prometheus monitoring stack, the cluster experienced API timeouts and pod scheduling failures due to insufficient node resources (t3.micro). Upgrading the node group to t3.medium resolved the issue and allowed the observability stack to deploy successfully.

## Key Lessons Learned

This project provided hands-on experience with:

* Debugging Terraform infrastructure provisioning
* Investigating AWS EKS node group failures
* Troubleshooting Kubernetes API timeouts
* Diagnosing autoscaling and metrics pipeline issues
* Correcting Kubernetes resource configuration errors
* Managing real-world operational failures across cloud and container platforms

These troubleshooting exercises closely reflect production DevOps and platform engineering workflows.

### Infrastructure Scaling Challenge

While deploying the Prometheus monitoring stack, the cluster experienced API timeouts and pod scheduling failures due to insufficient node resources (t3.micro). Upgrading the node group to t3.medium resolved the issue and allowed the observability stack to deploy successfully.

# Lessons Learned

Running observability stacks on very small Kubernetes nodes (t3.small) can lead to
API server timeouts and CRD installation failures due to resource pressure.
Increasing node size (t3.medium) resolved the issue.

## Getting Started

Follow these steps to deploy the Insurance Cloud Platform on AWS EKS. This section is tailored for quick portfolio demonstration.

1. Clone the repository
git clone https://github.com/<your-username>/insurance-cloud-platform.git
cd insurance-cloud-platform
2. Configure AWS CLI

Ensure your AWS CLI is set to the correct region and has sufficient permissions:

aws configure
# Set AWS Access Key, Secret Key, and default region (e.g., us-east-2)
3. Provision Infrastructure with Terraform

Navigate to the Terraform environment:

cd terraform/environments/dev

Initialize Terraform:

terraform init

Review the plan:

terraform plan

Apply the configuration to create your VPC, subnets, EKS cluster, and node groups:

terraform apply
# Confirm with "yes"

⚠️ Use t3.large or higher instance types for demo purposes to avoid Free Tier limitations.

4. Configure kubectl

Update kubeconfig to access your EKS cluster:

aws eks update-kubeconfig \
    --name insurance-dev-eks \
    --region us-east-2

Check nodes and cluster status:

kubectl get nodes
kubectl get pods -A
5. Deploy the Application

Navigate to the Kubernetes manifests folder:

cd ../../../kubernetes/insurance-app

Apply Deployment, Service, HPA, and Ingress manifests:

kubectl apply -f insurance-deployment.yaml
kubectl apply -f insurance-service.yaml
kubectl apply -f insurance-hpa.yaml
kubectl apply -f insurance-ingress.yaml

Check pod and ingress status:

kubectl get pods -n insurance-app
kubectl get ingress -n insurance-app
kubectl get hpa -n insurance-app
6. Deploy Monitoring (Optional)

Install Prometheus & Metrics Server for observability:

kubectl create namespace monitoring

# Apply CRDs manually first to avoid timeout issues
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/main/bundle.yaml

# Then deploy via Helm
helm install monitoring prometheus-community/kube-prometheus-stack \
    --namespace monitoring

Verify pods and services:

kubectl get pods -n monitoring
kubectl get svc -n monitoring
7. Cleanup

To destroy the infrastructure when finished:

cd terraform/environments/dev
terraform destroy

This ensures you don’t incur AWS charges for t3.large instances after your portfolio demo

docs: Add comprehensive Getting Started guide and project setup instructions
- Documented step-by-step instructions for setting up the Insurance Cloud Platform project from zero.
- Included environment setup using WSL on Windows, VS Code, Terraform, AWS CLI, kubectl, and Helm.
- Detailed Terraform workflow for provisioning VPC, subnets, EKS cluster, and node groups.
- Added instructions for deploying the sample insurance application, including Deployment, Service, HPA, and Ingress manifests.
- Included optional monitoring setup with Prometheus and kube-prometheus-stack via Helm.
- Added cleanup instructions to destroy AWS resources after the demo.
- Emphasizes Free Tier limitations and recommended t3.large instances for portfolio demonstrations.
- Ensures reproducibility for interview discussions and GitHub portfolio showcase.

Author: Kofi Sefa