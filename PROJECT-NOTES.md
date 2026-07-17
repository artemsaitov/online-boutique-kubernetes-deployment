# Online Boutique Kubernetes Deployment Notes

## Project Overview

This project documents my local deployment and validation of Google Cloud's Online Boutique microservices application on Kubernetes using Docker Desktop.

The goal was to practise:

- Kubernetes Deployments and Services
- Namespaces
- Service discovery
- EndpointSlices
- Pod self-healing
- Redis ephemeral storage
- Logs and troubleshooting
- Local application access with port forwarding

## Environment

- macOS on Intel
- Docker Desktop Kubernetes
- Kubernetes v1.36.1
- kubectl v1.36.2
- Dedicated namespace: `online-boutique`

## Deployment

The application was deployed using the release manifest:

```bash
kubectl apply -f release/kubernetes-manifests.yaml