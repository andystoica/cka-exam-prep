#!/bin/bash
### Script for testing DNS connectivity inside Kubernetes
### At least one worker node has to join the cluster using ./worker-init.sh script
### Check readiness with kubectl get nodes before calling this script


### Test DNS functionality within K8s
kubectl apply -f busybox.yaml
printf "\n[1/3] Waiting 5 seconds to allow the pod to be ready...\n";sleep 5
kubectl get pods
printf "\n[2/3] Giving it another 5 seconds before executing nslookup...\n";sleep 5
kubectl exec -it busybox nslookup kubernetes.default
printf "\n[3/3] Removing the bosybox pod. This may take a few seconds...\n"
kubectl delete pod/busybox