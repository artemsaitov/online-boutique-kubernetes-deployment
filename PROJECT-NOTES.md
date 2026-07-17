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

## Prometheus and Grafana Monitoring

The `kube-prometheus-stack` Helm chart was installed in a separate `monitoring` namespace.

The standard Helm repository command repeatedly timed out while reading the repository index. The chart was therefore installed directly from the official OCI registry:

```bash
helm install monitoring \
  oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values portfolio-k8s/monitoring-values.yaml \
  --timeout 15m
```

The installation provided Prometheus, Grafana, Alertmanager, kube-state-metrics, node exporter, and the Prometheus Operator.

All monitoring Pods were validated with:

```bash
kubectl get pods -n monitoring
```

Grafana was accessed locally using:

```bash
kubectl port-forward \
  -n monitoring \
  service/monitoring-grafana \
  3000:80
```

The Kubernetes networking dashboard was filtered to the `online-boutique` namespace and displayed live network activity for the application Pods.