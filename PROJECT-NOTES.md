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

## Horizontal Scaling Test

The `cartservice` Deployment was scaled from one replica to three:

```bash
kubectl scale deployment cartservice \
  -n online-boutique \
  --replicas=3


All cart Pods were then deleted during a self-healing test. The Deployment recreated the desired three replicas automatically.

After validation, the Deployment was scaled back to one replica:
kubectl scale deployment cartservice \
  -n online-boutique \
  --replicas=1
  This demonstrated horizontal scaling, Service endpoint updates, and Deployment self-healing.

  ## Readiness and Rollback Tests

### Failed Readiness Probe

The `cartservice` readiness probe was temporarily changed to use invalid gRPC port `9999`.

The replacement Pod started but remained `0/1 Running`, meaning the container was running but was not ready to receive traffic.

Kubernetes kept the previous healthy Pod active while the new rollout was unable to complete. The unready Pod was not treated as a ready Service endpoint.

The correct configuration was restored with:

```bash
kubectl apply -k portfolio-k8s/overlays/local
```

The Deployment returned to one healthy `1/1 Running` Pod.

### Failed Image and Rollback

A nonexistent image tag was assigned to `cartservice`:

```bash
kubectl set image deployment/cartservice \
  -n online-boutique \
  server=us-central1-docker.pkg.dev/google-samples/microservices-demo/cartservice:bad-version
```

The replacement Pod entered `ErrImagePull` or `ImagePullBackOff`, while the previous healthy Pod remained available.

The failed revision was rolled back:

```bash
kubectl rollout undo deployment/cartservice \
  -n online-boutique
```

Because the Deployment is managed declaratively, the Kustomize overlay was reapplied afterward:

```bash
kubectl apply -k portfolio-k8s/overlays/local
```

This restored the live cluster to the Git-managed desired state.