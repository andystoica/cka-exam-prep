# Logging & Monitoring 5%

- [1. Monitoring cluster components](#1-monitoring-cluster-components)
- [2. Monitoring application logs](#2-monitoring-application-logs)

## 1. Monitoring cluster components

Monitoring is done through third party solutions. Metrics Server is a lightweight in memmory monitoring solution commonly used with k8s clusters. You can have one Metrics Server per cluster.

To install the Metrics Server on the master node:

```bash
git clone https://github.com/kubernetes-incubator/metrics-server.git
kubectl apply –f metrics-server/deploy/1.8+/
```

To remove the Metrics Server, use delete

```bash
kubectl delete –f metrics-server/deploy/1.8+/
```

To read metrics data for nodes and pods

```bash
kubectl top node
kubectl top pod
```

## 2. Monitoring application logs

If there are multiple containers running inside the pod, the container name needs to be specified. Using the `-f` flag allows live streaming of log events.

```bash
kubectl logs -f webapp-pod webapp-container
```
