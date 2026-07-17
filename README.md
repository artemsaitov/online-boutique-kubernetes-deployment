# Online Boutique Kubernetes Deployment

This project documents my deployment, validation, and troubleshooting of Google Cloud’s **Online Boutique** microservices application on a local Kubernetes cluster using Docker Desktop.

The goal was to gain hands-on experience with Kubernetes workloads, service discovery, networking, self-healing, ephemeral storage, and troubleshooting.

## Project Overview

Online Boutique is a cloud-native e-commerce application composed of multiple microservices that communicate primarily through gRPC.

The deployed workloads include:

- Frontend
- Cart service
- Checkout service
- Product catalog service
- Currency service
- Payment service
- Shipping service
- Email service
- Recommendation service
- Advertisement service
- Load generator
- Redis

## Technologies Used

- Kubernetes
- Docker Desktop
- kubectl
- Git and GitHub
- Redis
- YAML
- gRPC microservices
- Kubernetes Services
- EndpointSlices

## Local Environment

- macOS on Intel
- Docker Desktop Kubernetes
- Kubernetes v1.36.1
- kubectl v1.36.2
- Dedicated namespace: `online-boutique`

## Architecture

Most microservices are exposed internally through Kubernetes `ClusterIP` Services.

The frontend communicates with backend services using Kubernetes DNS names:

```text
frontend
├── productcatalogservice:3550
├── currencyservice:7000
├── cartservice:7070
├── recommendationservice:8080
├── shippingservice:50051
├── checkoutservice:5050
└── adservice:9555

## Deployment

Clone the repository:

```bash
git clone https://github.com/artemsaitov/online-boutique-kubernetes-deployment.git
cd online-boutique-kubernetes-deployment
git switch portfolio-deployment