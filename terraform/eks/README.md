# Online Boutique on Amazon EKS with Terraform

This project deploys Google Cloud's **Online Boutique** microservices application to **Amazon EKS** using Terraform.

The infrastructure is designed as a temporary, cost-conscious learning environment for practicing Terraform, Kubernetes, and Amazon EKS deployment workflows.

## Architecture

Terraform provisions the following AWS resources:

* Amazon EKS cluster
* Amazon VPC
* Two public subnets across two Availability Zones
* Internet Gateway
* Public route table
* EKS managed node group
* Two `t3.small` EC2 worker nodes
* Amazon VPC CNI
* CoreDNS
* kube-proxy
* AWS Elastic Load Balancer for the frontend

## Technologies

* AWS
* Amazon EKS
* Terraform
* Kubernetes
* Docker
* AWS CLI
* kubectl
* Kustomize
* Kubernetes manifests

## Project Structure

```text
terraform/eks/
├── eks.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars.example
├── variables.tf
├── versions.tf
├── vpc.tf
└── README.md
```

## Prerequisites

Install the following tools:

* Terraform
* AWS CLI
* kubectl
* Git

Configure your AWS credentials and verify authentication:

```bash
aws sts get-caller-identity
```

## Deploy the Infrastructure

### 1. Navigate to the Terraform Directory

```bash
cd terraform/eks
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Format and Validate the Configuration

```bash
terraform fmt
terraform validate
```

### 4. Create a Terraform Plan

```bash
terraform plan \
  -var-file=terraform.tfvars.example \
  -out=eks-create.tfplan
```

### 5. Apply the Terraform Plan

```bash
terraform apply eks-create.tfplan
```

## Configure kubectl

Update your local kubeconfig so that `kubectl` can communicate with the EKS cluster:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name online-boutique-dev
```

Verify the current Kubernetes context:

```bash
kubectl config current-context
```

## Verify the EKS Cluster

Verify that the worker nodes successfully joined the cluster:

```bash
kubectl get nodes
```

Expected output:

```text
NAME                          STATUS   ROLES    AGE   VERSION
ip-10-20-x-x.ec2.internal     Ready    <none>   ...   ...
ip-10-20-x-x.ec2.internal     Ready    <none>   ...   ...
```

Verify that the EKS system components are running:

```bash
kubectl get pods -n kube-system
```

The following components should be running:

* `aws-node`
* `coredns`
* `kube-proxy`

## Deploy Online Boutique

From the repository root, apply the Online Boutique Kubernetes manifests:

```bash
kubectl apply -f release/kubernetes-manifests.yaml
```

Monitor the application while the pods are starting:

```bash
kubectl get pods -w
```

Press `Ctrl+C` after all pods reach the `Running` status.

Verify all workloads:

```bash
kubectl get pods
```

The deployment includes the following services:

* `adservice`
* `cartservice`
* `checkoutservice`
* `currencyservice`
* `emailservice`
* `frontend`
* `loadgenerator`
* `paymentservice`
* `productcatalogservice`
* `recommendationservice`
* `redis-cart`
* `shippingservice`

## Access the Application

Check the external frontend service:

```bash
kubectl get service frontend-external
```

Example output:

```text
NAME                TYPE           CLUSTER-IP      EXTERNAL-IP
frontend-external   LoadBalancer   172.20.x.x      <load-balancer-hostname>
```

Copy the hostname displayed under `EXTERNAL-IP` and open it in a browser.

The Online Boutique storefront should load through the AWS Elastic Load Balancer.

> The load balancer may take several minutes to become available after the service is created.

## Troubleshooting

### Worker Nodes Remain `NotReady`

Check whether the EKS system add-ons are installed:

```bash
kubectl get pods -n kube-system
```

The Terraform EKS configuration should include the following add-ons:

```hcl
addons = {
  vpc-cni = {
    before_compute = true
  }

  kube-proxy = {}
  coredns   = {}
}
```

Without the Amazon VPC CNI, worker nodes may register with the EKS cluster but remain in the `NotReady` state.

### `NodeCreationFailure`

Check the following configuration areas:

* Public IP assignment on worker nodes
* Internet Gateway route
* Node IAM role policies
* VPC DNS support
* EKS access entry
* EC2 bootstrap logs

The worker-node IAM role should include these policies:

```text
AmazonEKSWorkerNodePolicy
AmazonEC2ContainerRegistryReadOnly
AmazonEKS_CNI_Policy
```

### Check Pod Status

```bash
kubectl get pods
```

View detailed information about a pod:

```bash
kubectl describe pod <pod-name>
```

View the logs for a pod:

```bash
kubectl logs <pod-name>
```

### Check Service Status

```bash
kubectl get services
```

Inspect the external frontend service:

```bash
kubectl describe service frontend-external
```

## Cleanup

The EKS control plane, EC2 worker nodes, EBS volumes, NAT-related resources, and Elastic Load Balancer may incur AWS charges.

Delete the Kubernetes resources before destroying the Terraform infrastructure:

```bash
kubectl delete -f release/kubernetes-manifests.yaml
```

Confirm that the frontend service has been deleted:

```bash
kubectl get service frontend-external
```

Wait until the AWS Elastic Load Balancer has been removed.

Navigate to the Terraform directory:

```bash
cd terraform/eks
```

Create a Terraform destroy plan:

```bash
terraform plan \
  -destroy \
  -var-file=terraform.tfvars.example \
  -out=eks-destroy.tfplan
```

Apply the destroy plan:

```bash
terraform apply eks-destroy.tfplan
```

Verify that the Terraform state is empty:

```bash
terraform state list
```

If the command returns no resources, the Terraform-managed infrastructure has been successfully destroyed.

## Result

The complete Google Online Boutique application was successfully deployed to Amazon EKS.

All 12 application workloads ran successfully with zero restarts, and the frontend was publicly accessible through an AWS Elastic Load Balancer.

## Key Lessons

* EKS worker nodes can join the cluster but remain `NotReady` when the Amazon VPC CNI is missing.
* Public worker nodes require public IP assignment and a working Internet Gateway route.
* EKS add-ons should be explicitly managed through Terraform.
* Kubernetes `LoadBalancer` services create AWS resources that should be deleted before running `terraform destroy`.
* Terraform state files and saved plan files must not be committed to Git.
* Temporary cloud environments should be destroyed after validation to reduce costs.

## Security and Git Notes

Do not commit Terraform state, plan files, or sensitive variable files.

Recommended `.gitignore` entries:

```gitignore
.terraform/
*.tfstate
*.tfstate.*
*.tfplan
terraform.tfvars
.terraform.lock.hcl
crash.log
```

The `terraform.tfvars.example` file may be committed because it should contain only example values and no sensitive information.
