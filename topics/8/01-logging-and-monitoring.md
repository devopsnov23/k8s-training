# Logging and Monitoring 

## Kubernetes Events 
Kubernetes Events are created when other resources have state changes, errors, or other messages that should be broadcast to the system.  

It provides insight into what is happening inside a cluster such as what decisions were made by Scheduler or why some pods were evicted froma node. 

```yaml
cloud_user_p_01431456@k8s:~$ kubectl get events 
No events found in default namespace.
cloud_user_p_01431456@k8s:~$ kubectl run dummy-pod --image=dummy 
pod/dummy-pod created
cloud_user_p_01431456@k8s:~$ kubectl events 
LAST SEEN   TYPE      REASON      OBJECT          MESSAGE
6s          Normal    Scheduled   Pod/dummy-pod   Successfully assigned default/dummy-pod to kind-worker2
6s          Normal    Pulling     Pod/dummy-pod   Pulling image "dummy"
6s          Warning   Failed      Pod/dummy-pod   Failed to pull image "dummy": rpc error: code = Unknown desc = failed to pull and unpack image "docker.io/library/dummy:latest": failed to resolve reference "docker.io/library/dummy:latest": pull access denied, repository does not exist or may require authorization: server message: insufficient_scope: authorization failed
6s          Warning   Failed      Pod/dummy-pod   Error: ErrImagePull
6s          Normal    BackOff     Pod/dummy-pod   Back-off pulling image "dummy"
6s          Warning   Failed      Pod/dummy-pod   Error: ImagePullBackOff
cloud_user_p_01431456@k8s:~$ 
```

## Monitoring Cluster Components 

Install metric server and monitor cluster components 

```yaml
cloud_user_p_8e31226b@k8s:~$ cat components.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
    rbac.authorization.k8s.io/aggregate-to-admin: "true"
    rbac.authorization.k8s.io/aggregate-to-edit: "true"
    rbac.authorization.k8s.io/aggregate-to-view: "true"
  name: system:aggregated-metrics-reader
rules:
- apiGroups:
  - metrics.k8s.io
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
rules:
- apiGroups:
  - ""
  resources:
  - nodes/metrics
  verbs:
  - get
- apiGroups:
  - ""
  resources:
  - pods
  - nodes
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server-auth-reader
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: extension-apiserver-authentication-reader
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server:system:auth-delegator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:auth-delegator
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    k8s-app: metrics-server
  name: system:metrics-server
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:metrics-server
subjects:
- kind: ServiceAccount
  name: metrics-server
  namespace: kube-system
---
apiVersion: v1
kind: Service
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  ports:
  - name: https
    port: 443
    protocol: TCP
    targetPort: https
  selector:
    k8s-app: metrics-server
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    k8s-app: metrics-server
  name: metrics-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: metrics-server
  strategy:
    rollingUpdate:
      maxUnavailable: 0
  template:
    metadata:
      labels:
        k8s-app: metrics-server
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --kubelet-insecure-tls 
        - --metric-resolution=15s
        image: registry.k8s.io/metrics-server/metrics-server:v0.6.4
        imagePullPolicy: IfNotPresent
        livenessProbe:
          failureThreshold: 3
          httpGet:
            path: /livez
            port: https
            scheme: HTTPS
          periodSeconds: 10
        name: metrics-server
        ports:
        - containerPort: 4443
          name: https
          protocol: TCP
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /readyz
            port: https
            scheme: HTTPS
          initialDelaySeconds: 20
          periodSeconds: 10
        resources:
          requests:
            cpu: 100m
            memory: 200Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
        volumeMounts:
        - mountPath: /tmp
          name: tmp-dir
      nodeSelector:
        kubernetes.io/os: linux
      priorityClassName: system-cluster-critical
      serviceAccountName: metrics-server
      volumes:
      - emptyDir: {}
        name: tmp-dir
---
apiVersion: apiregistration.k8s.io/v1
kind: APIService
metadata:
  labels:
    k8s-app: metrics-server
  name: v1beta1.metrics.k8s.io
spec:
  group: metrics.k8s.io
  groupPriorityMinimum: 100
  insecureSkipTLSVerify: true
  service:
    name: metrics-server
    namespace: kube-system
  version: v1beta1
  versionPriority: 100
cloud_user_p_8e31226b@k8s:~$
cloud_user_p_8e31226b@k8s:~$ kubectl get po -n kube-system | grep metrics 
metrics-server-9d8d44575-phvhg               1/1     Running   0          4m4s
cloud_user_p_8e31226b@k8s:~$ kubectl top nodes 
NAME                 CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
kind-control-plane   162m         8%     639Mi           8%        
kind-worker          48m          2%     187Mi           2%        
kind-worker2         42m          2%     180Mi           2%        
cloud_user_p_8e31226b@k8s:~$
cloud_user_p_8e31226b@k8s:~$ kubectl top pods 
NAME    CPU(cores)   MEMORY(bytes)   
httpd   1m           5Mi             
nginx   0m           3Mi             
cloud_user_p_8e31226b@k8s:~$ 
```
### Managing Application Logs 

```yaml
cloud_user_p_8e31226b@k8s:~$ kubectl logs nginx 
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2023/11/17 09:22:01 [notice] 1#1: using the "epoll" event method
2023/11/17 09:22:01 [notice] 1#1: nginx/1.25.3
2023/11/17 09:22:01 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14) 
2023/11/17 09:22:01 [notice] 1#1: OS: Linux 6.2.0-1018-gcp
2023/11/17 09:22:01 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1048576:1048576
2023/11/17 09:22:01 [notice] 1#1: start worker processes
2023/11/17 09:22:01 [notice] 1#1: start worker process 35
2023/11/17 09:22:01 [notice] 1#1: start worker process 36
cloud_user_p_8e31226b@k8s:~$
```
