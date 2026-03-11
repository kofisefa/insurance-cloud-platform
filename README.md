# Insurance Cloud Platform

This project demonstrates a production-style AWS cloud infrastructure
built using Terraform, Kubernetes, Docker, Jenkins, Helm, and Ansible.

The platform simulates a microservices-based insurance quote processing
system deployed on Amazon EKS.

## Operational Issues & Troubleshooting

During the development of the Insurance Cloud Platform, several real-world operational issues were encountered while deploying and scaling the Kubernetes workloads on AWS EKS. These issues required debugging across multiple layers including Terraform infrastructure, Kubernetes resources, and AWS services.

Documenting these challenges demonstrates practical platform engineering and operational troubleshooting experience.

---

### 1. EKS Node Group Creation Failure

**Issue**

While creating the EKS node group using Terraform, the node group entered a `CREATE_FAILED` state.

Error message:

```
AsgInstanceLaunchFailures: Could not launch On-Demand Instances.
InvalidParameterCombination - The specified instance type is not eligible for Free Tier.
```

**Root Cause**

The instance type configured for the node group was incompatible with AWS Free Tier restrictions.

**Resolution**

Updated the Terraform variable for node instance type to a supported instance class.

Example Terraform variable:

```hcl
variable "node_instance_type" {
  default = "t3.large"
}
```

This allowed the node group to launch successfully and register worker nodes with the cluster.

---

### 2. Kubernetes CRD Installation Failures (Prometheus Stack)

**Issue**

While installing the Prometheus monitoring stack using Helm, the installation repeatedly failed with errors such as:

```
http2: client connection lost
TLS handshake timeout
server was unable to return a response in the time allotted
```

**Root Cause**

The cluster was running on minimal compute capacity. Large CRD resources caused the Kubernetes API server to timeout while processing the requests.

**Resolution**

Increased node capacity by upgrading the node group instance type.
Once sufficient resources were available, the CRDs were able to install without API timeout errors.

---

### 3. Horizontal Pod Autoscaler Showing `<unknown>` CPU Metrics

**Issue**

After deploying a Horizontal Pod Autoscaler (HPA), the metrics column displayed:

```
cpu: <unknown>/50%
```

**Root Cause**

The deployment did not define CPU resource requests.
HPA calculates utilization as:

```
CPU Utilization = Current Usage / Requested CPU
```

Without CPU requests defined, Kubernetes cannot calculate utilization.

**Resolution**

Added resource requests and limits to the container specification.

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "256Mi"
```

After applying the updated deployment, the HPA began reporting metrics correctly.

---

### 4. Metrics Server Communication Issues

**Issue**

The metrics server initially failed to collect metrics from Kubernetes nodes, preventing HPA from functioning.

**Root Cause**

EKS kubelets use certificates that the metrics-server cannot validate by default.

**Resolution**

Updated the metrics-server deployment arguments to allow secure communication with kubelets:

```
--kubelet-insecure-tls
--kubelet-preferred-address-types=InternalIP
```

Once updated, node and pod metrics became available using:

```
kubectl top nodes
kubectl top pods
```

---

### 5. Kubernetes YAML Schema Errors

**Issue**

Deployment updates failed with:

```
strict decoding error: unknown field "resources"
```

**Root Cause**

The `resources` block was incorrectly placed outside the container specification.

**Resolution**

Moved the `resources` configuration inside the container definition:

```yaml
containers:
- name: insurance-api
  image: nginx
  resources:
    requests:
      cpu: "100m"
      memory: "128Mi"
```

---

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

Author: Kofi Sefa