# Application Lifecycle Management 8%

- [1. Rolling Updates and Rollbacks](#1-rolling-updates-and-rollbacks)
- [2. Configure Applications](#2-configure-applications)
  - [2.1. Entry points and command arguments](#21-entry-points-and-command-arguments)
  - [2.2. ConfigMaps](#22-configmaps)
  - [2.4. Secrets](#24-secrets)
  - [2.4. Environment variables](#24-environment-variables)
- [3. Multi container pods](#3-multi-container-pods)

## 1. Rolling Updates and Rollbacks

To **create a deployment** declaratively, use a mafinest file

```bash
kubectl apply -f webapp-deployment.yaml
```

---

To **update a deployment**, edit the manifest file with the new image

```bash
kubectl apply -f webapp-deployment.yaml
```

or imperatively (not recommended)

```bash
kubectl set image webapp-deployment.yaml webapp-container=webapp-image:2.0
```

---

To get the **rollout status** for a particular application

```bash
kubectl rollout status deployment/webapp-deployment
```

To get the **rollout history** for a particular application

```bash
kubectl rollout history deployment/webapp-deployment
```

---

To **roll back / undo** a rollout

```bash
kubectl rollout undo deployment/webapp-deployment
kubectl rollout undo deployment/webapp-deployment --to-revision=2
```

---

Rollout strategies `spec.strategyType`

- **Rolling Update (default)** - replaces each pod replica incrementally to prevent downtimes.
- **Recreate** - Recreates new pods after all existing pods have been destroyed. Causes downtime.

## 2. Configure Applications

### 2.1. Entry points and command arguments

Configuration is done inside the pod manifest under the container spect. `command` parammeter replaces the `ENTRYPOINT` directive in the Dockerfile, `args` replaces the `CMD`.

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: webapp-pod

spec:
  containers:
    - name: webapp-container
      image: webapp-image
      command: ['node']
      args: ['app.js']
```

---

### 2.2. ConfigMaps

ConfigMaps hold key value pairs which can be retreived from within Pod definitions. ConfigMaps can be created imperatively:

```bash
kubectl create configmap app-config \
        --from-literal=DB_USER=dbadmin \
        --from-literal=DB_PASS=insecure
```

or from a key:value properties file:

```bash
kubectl create configmap app-config \
        --from-file=app-config.properties
```

---

Or declaratively using a yaml manifest:

```yaml
apiVersion: v1
kind: ConfigMap

metadata:
  name: app-config

data:
  DB_USER: db_admin
  DB_PASS: insecure
```

```bash
kubectl create -f app-config.yaml
```

---

To view config maps in current namespace:

```bash
kubectl get configmaps
kubectl describe configmaps
```

---

### 2.4. Secrets

Secrets are similar to ConfigMaps. They hold key value pairs which can be retreived from within Pod definitions. Data in secrets needs to be hashed with Base64 and is hidden by default.

Create secrets imperatively:

```bash
kubectl create secret generic app-secret \
        --from-literal=DB_USER=dbadmin \
        --from-literal=DB_PASS=moreSecure
```

or from a key:value properties file:

```bash
kubectl create secret generic app-secret \
        --from-file=app-secret.properties
```

---

To create secrets declarativery, values need to be hashed with Base64 first.

```bash
echo -n 'db_admin' | base64
echo -n 'secure' | base64
```

```yaml
apiVersion: v1
kind: Secret

metadata:
  name: app-secret

data:
  DB_USER: ZGJfYWRtaW4=
  DB_PASS: c2VjdXJl
```

---

To view secrets in current namespace:

```bash
kubectl get secrets
kubectl describe secrets
```

To view the secrets value in hashed format, retreive the object in YAML format.

```bash
kubectl get secret app-secret -o yaml
```

---

### 2.4. Environment variables

Environmental variables are passed inside the Pod manifest. They are usually retreived from other ConfigMap or Secret objects.

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: webapp-pod

spec:
  containers:
    - name: webapp-container
      image: webapp-image

      # import all key value pairs
      envFrom:
        - configMapRef:
            name: app-config
          secretRef:
            name: app-secret

      # or a single variable
      env:
        - name: DB_USER
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: DB_USER
        - name: DB_PASS
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: DB_PASS

      # or as a volume
      volumes:
        - name: webapp-config-volume
          configMap:
            name: app-config
        - name: webapp-secret-volume
          secret:
            secretName: app-secret
```

## 3. Multi container pods

Multiple containers can be defined within the same pod definition. The containers share the same lifecycle, networking and volumes within the pod. They can access eachother using localhost.

If either container terminates, the pod is terminated (or recreated if part of a ReplicaSet of Deployment).

InitContainers can be defined in addition to normal containers. They are used to run one off tasks before the main containers can start. The main containers will only start if the initContainers have successfully terminated. If init container terminated for some other reason, the whole pod is terminated.

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: webapp-pod

spec:
  # run one off tasks before main containers are brought up
  initContainers:
    - name: webapp-fetch-container
      image: webapp-fetch-image
  # only if initContainers have successfully terminated
  contaiers:
    - name: webapp-container
      image: webapp-image
    - name: webapp-logging-container
      image: webapp-logging-image
```
