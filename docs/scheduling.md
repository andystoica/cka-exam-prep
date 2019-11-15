# Scheduling

**Table of contents**

- [Labels & Selectors](#labels--selectors)
  - [Pod](#pod)
  - [ReplicaSet](#replicaset)
  - [Service](#service)
  - [Deployement](#deployement)
- [Taints & Tolerations](#taints--tolerations)
  - [Tainting nodes with kubectl](#tainting-nodes-with-kubectl)
  - [Declaring tolerations on pods](#declaring-tolerations-on-pods)
- [Affinity and Anti-Affinity](#affinity-and-anti-affinity)
  - [Pod affinity](#pod-affinity)
  - [Deployment affinity](#deployment-affinity)
- [Resource requirements](#resource-requirements)
- [Daemon Sets](#daemon-sets)
- [Static Pods](#static-pods)
- [Multiple schedulers and configuration](#multiple-schedulers-and-configuration)
  - [Scheduling log and events](#scheduling-log-and-events)
- [Manual scheduling](#manual-scheduling)

---

## Labels & Selectors

To get a list of pods based on a particular set of labels:

```bash
kubectl get pods --selector key=value
```

### Pod

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: webapp-pod
  labels:
    app: webapp

spec:
  containers:
    - name: webapp-container
      image: nginx
```

### ReplicaSet

```yaml
apiVersion: apps/v1
kind: ReplicaSet

metadata:
  name: webapp-rs

spec:
  replicas: 3

  selector:
    matchLabels:
      app: webapp

  template:
    metadata:
      name: webapp-pod
      labels:
        app: webapp
        tier: frontend

    containers:
      - name: webapp-container
        image: nginx
```

### Service

```yaml
apiVersion: apps/v1
kind: Service

metadata:
  name: webapp-svc

spec:
  selector:
    app: webapp
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
```

### Deployement

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: webapp-deployment

spec:
  replicas: 3

  selector:
    matchLabels:
      app: webapp

  template:
    metadata:
      labels:
        app: webapp

    spec:
      containers:
        - name: webapp-container
          image: nginx
          ports:
            - containerPort: 80
```

---

## Taints & Tolerations

**Taints** are for nodes, **tolerations** are for pods. Tainting a node prevents pods from being scheduled on that node, unless the pod has a matching toleration for that taint.

### Tainting nodes with kubectl

```bash
kubectl taint node node01 tier=frontend:NoSchedule
```

Tainting effects on pods without a matching toleration:

- `NoSchedule` - Don't schedule any new pods. Keep existing ones even if they don't have a matching toleration.

- `PreferNoSchedule` - Don't schedule new pods unless there are no other nodes available. Use a last resort to make sure the pod doesn't hang in a pending state.

- `NoExec` - As NoSchedule but evicts any existing pods already scheduled without a matching toleration.

### Declaring tolerations on pods

Important: Adding a toleration to a pod only allows the pod to be scheduled on a node with a matching taint. It **does not guarantee** that the pod won't be scheduled on a untainted node.

Values need to be enclosed inside quotes.

Available operators: `Exists`, `Equal`

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: webapp-pod

spec:
  containers:
    - name: webapp-container
      image: nginx
  tolerations:
    - key: 'tier'
      operator: 'Equal'
      value: 'frontend'
      effect: 'NoSchedule'
```

---

## Affinity and Anti-Affinity

Affinity is used as a node selection mechanism for pods. It allows a pod to specify a particular preference (affinity) towards certain nodes. The affinity mechanism uses labels set on nodes.

To label a node using kubectl

```bash
kubectl label node node01 size=large
```

Operators: `In`, `NotIn`, `Exists`, `DoesNotExist`, `Gt`, `Lt`
Affinity types:

- `requiredDuringSchedulingIgnoredDuringExecution`
- `preferredDuringSchedulingIgnoredDuringExecution`

### Pod affinity

Afinity is declared in pod definition under `spec.affinity`

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: webapp-pod

spec:
  containers:
    - name: webapp-container
      image: nginx

  affinity:
    nodeAffinity:
      requirerequiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: size
                operator: in
                values: large
```

### Deployment affinity

Afinity is declared in pod definition template under `spec.affinity`

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: webapp-deployment

spec:
  replicas: 3

  selector:
    matchLabels:
      app: webapp

  template:
    metadata:
      name: webapp-pod
      labels:
        app: webapp

    spec:
      containers:
        - name: webapp-container
          image: nginx

       affinity:
        nodeAffinity:
          requirerequiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: size
                    operator: in
                    values: large
```

---

## Resource requirements

Resource requirements are declared for each container under `container[].resources`. Default limits are 512Mi and 1 vCPU.

- `resources.requests`: Soft limits. Used during scheduling.
- `resources.limits`: Hard limits. Container will be terminated if memory is exceeded, cpu will be throttled.

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: webapp-pod

spec:
  containers:
    - name: webapp-container
      image: webapp-image
      resources:
        requests:
          memory: 256Mi
          cpu: 0.5
        limits:
          memory: 512Mi
          cpu: 2
```

---

## Daemon Sets

Ensure that a single copy of a particular pod is deployed on _every_ node in the cluster. Definition is very similar to ReplicaSets.

```yaml
apiVersion: apps/v1
kind: DaemonSet

metadata:
  name: logging-ds

spec:
  selector:
    matchLabels:
      app: logging-app

  template:
    metadata:
      name: logging-pod
      labels:
        app: logging-app

    spec:
      containers:
        - name: logging-container
          image: logging-image
```

## Static Pods

Created only by the _kubelet_ from local manifest files. Read-only mirror objects are created on the API Server which can not be modified with kubectl or API calls. These objects can only be modified by editing the local manifests on each pod.

To find the location of local manifests folder, ssh into each node:

- Option 1 (kubeadm setups): Run `ps -aux | grep kubelet` to retreive location to `kubelet/config.yaml` file. Inside the configuration file, look for `staticPodPath: /etc/Kubernetes/manifests` parameter

- Option 2 (hard way setups): inspect `kubelet.service` file for `--pod-manifest-path=/etc/Kubernetes/manifests` parameter

Kubelet is watching the local folder for new pod manifests or changes to existing ones. Pods will only be deployed on the same node.

## Multiple schedulers and configuration

Multiple schedulers can be installed on the master node. With `kubeadm` shedullers are deployed as static pods on the master node. An additional scheduller need to specify the `--scheduler-name=additional-scheduler` property and use a different port than the `default-scheduler`.

- In clusters with a single master noder, `--leader-elect=false` has to be set.
- in HA cluster with multiple masters, `--leader-elect=true` and `--lock-object-name=additional-scheduler` need to be set

Custom schedulers are declared in the pod definitions under `spec.schedulerName`

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: webapp-pod

spec:
  containers:
    - name: webapp-container
      image: nginx
  schedulerName: additional-scheduler
```

### Scheduling log and events

Scheduling logs are available by inspectic the scheduler's pod logs

```bash
kubectl logs additional-scheduler -n kube-system
```

Scheduling events are available by quering the API for events

```bash
kubectl get events
```

## Manual scheduling

See: [k8s.io - Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/)

Scheduling a pod to a specific node without a scheduler. Set the `nodeName: node02` property in the pod manifest before creation.

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: webapp-pod

spec:
  containers:
    - name: webapp-container
      image: webapp-image
  nodeName: node02
```

---
