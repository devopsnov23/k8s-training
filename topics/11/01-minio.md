### Minio Deployment

```yaml
cloud_user_p_d9227775@cloudshell:~$ cat minio-dev.yaml 
# Deploys a new Namespace for the MinIO Pod
apiVersion: v1
kind: Namespace
metadata:
  name: minio-dev # Change this value if you want a different namespace name
  labels:
    name: minio-dev # Change this value to match metadata.name
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
  namespace: minio-dev
  labels:
    app: minio
spec:
  replicas: 1
  template:
    metadata:
      name: minio
      labels:
        app: minio
    spec:
      volumes:
        - name: data
          emptyDir:
            sizeLimit: 100Mi
      containers:
        - name: minio
          image: quay.io/minio/minio:latest
          imagePullPolicy: IfNotPresent
          livenessProbe:
            httpGet:
              path: /minio/health/live
              port: 9000
            initialDelaySeconds: 120
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: /minio/health/ready
              port: 9000
            initialDelaySeconds: 120
            periodSeconds: 20

          volumeMounts:
            - mountPath: /data
              name: data
          command:
            - /bin/bash
            - -c
          args:
              - minio server /data --console-address :9090
      restartPolicy: Always
  selector:
    matchLabels:
      app: minio
---
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: minio-dev
spec:
  selector:
    app: minio
  ports:
    - port: 9090
      name: console
    - port: 9000
      name: s3
  type: LoadBalancer 
cloud_user_p_d9227775@cloudshell:~$
```
