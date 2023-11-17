# Security 
There are 3 steps that Kubernetes uses to enforce security access and permissions – Authentication, Authorization and Admission.

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/27b2a77f-bd85-42d8-98e9-0645eaa0b474)

## Authentication 
- Kubernetes assumes that ‘users’ are managed outside of Kubernetes
- Kubernetes uses authenticating proxy, bearer tokens, client certificates, or HTTP basic authorization to authenticate API requests through authentication plugins.

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/1ed71e05-0f67-49c2-b924-8c0c0818cd28)

## Service Accounts 
Whenever you access your Kubernetes cluster with kubectl, you are authenticated by Kubernetes with your user account. User accounts are meant to be used by humans. But when a pod running in the cluster wants to access the Kubernetes API server, it needs to use a service account instead. Service accounts are just like user accounts but for non-humans.

```yaml
$ kubectl create deployment nginx1 --image=nginx
deployment.apps/nginx1 created
$ kubectl get pods
NAME                      READY   STATUS    RESTARTS   AGE
nginx1-585f98d7bf-84rxg   1/1     Running   0          12s

$ kubectl get pod nginx1-585f98d7bf-84rxg -o yaml
apiVersion: v1
kind: Pod
metadata:
  (...)
spec:
  containers:
  - image: nginx
    (...)
  serviceAccount: default
  serviceAccountName: default
```
Creating Your Own Service Accounts
```yaml
$ kubectl create serviceaccount nginx-serviceaccount
serviceaccount/nginx-serviceaccount created
$ cat nginx-sa.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nginx-serviceaccount
$ kubectl apply -f nginx-sa.yaml
serviceaccount/nginx-serviceaccount created
$ kubectl get serviceaccounts
NAME                   SECRETS   AGE
default                1         3h14m
nginx-serviceaccount   1         72s
$
```

Assigning Permissions to a Service Account
```yaml
kubectl create rolebinding nginx-sa-readonly \
  --clusterrole=view \
  --serviceaccount=default:nginx-serviceaccount \
  --namespace=default
```

Specifying ServiceAccount For Your Pod
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx1
  labels:
    app: nginx1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx1
  template:
    metadata:
      labels:
        app: nginx1
    spec:
      serviceAccountName: nginx-serviceaccount
      containers:
      - name: nginx1
        image: nginx
        ports:
        - containerPort: 80
```

## Kubeconfig 
Kubectl interacts with the kubernetes cluster using the details available in the Kubeconfig file. By default, kubectl looks for the config file in the /.kube location.

### List all cluster contexts
```yaml
cloud_user_p_8e31226b@k8s:~$ kubectl config get-contexts
CURRENT   NAME        CLUSTER     AUTHINFO    NAMESPACE
*         kind-kind   kind-kind   kind-kind   
cloud_user_p_8e31226b@k8s:~$
```

### Set the current context
```yaml
cloud_user_p_8e31226b@k8s:~$ kubectl config use-context kind-kind 
Switched to context "kind-kind".
cloud_user_p_8e31226b@k8s:~$
```
### Connect with the KUBECONFIG environment variable
You can set the KUBECONFIG environment variable with the kubeconfig file path to connect to the cluster. So wherever you are using the kubectl command from the terminal, the KUBECONFIG env variable should be available. If you set this variable, it overrides the current cluster context.
```yaml
cloud_user_p_8e31226b@k8s:~$ KUBECONFIG=$HOME/.kube/dev_cluster_config
cloud_user_p_8e31226b@k8s:~$ kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
httpd   1/1     Running   0          89m
nginx   1/1     Running   0          89m
cloud_user_p_8e31226b@k8s:~$ 

```
### Using Kubeconfig File With Kubectl
You can pass the Kubeconfig file with the Kubectl command to override the current context and KUBECONFIG env variable.

```yaml
cloud_user_p_8e31226b@k8s:~$ kubectl get nodes --kubeconfig=$HOME/.kube/dev_cluster_config
NAME                 STATUS   ROLES                  AGE    VERSION
kind-control-plane   Ready    control-plane,master   129m   v1.23.4
kind-worker          Ready    <none>                 128m   v1.23.4
kind-worker2         Ready    <none>                 128m   v1.23.4
cloud_user_p_8e31226b@k8s:~$
```

## Authorization 
In Kubernetes, there are several authorization mechanisms available that can be used to control access to resources in the cluster, including Node Authorization, Attribute-Based Access Control (ABAC), Role-Based Access Control (RBAC), Webhook, and the AlwaysDeny and AlwaysAllow modes.

### Node Authorization
Node Authorization is a specific type of authorization mode in Kubernetes that is used to authorize API requests made by kubelets. It is not intended for user authorization.

### ABAC (Attribute-Based Access Control)
Attribute-Based Access Control (ABAC) uses attributes to determine if a user or process has access to a resource. This policies consist of rules that match attributes in a user’s request with attributes in the policy.

### RBAC (Role-Based Access Control)
Role-Based Access Control (RBAC) is a widely adopted authorization mode in Kubernetes that allows cluster administrators to create roles and bind them to users, groups, or service accounts. Roles define a set of specific permissions, while role bindings attach these roles to the appropriate entities, granting administrators precise control over resource access.

### Webhook
Webhook authorization mode allows for custom authorization logic by delegating the authorization decision to an external HTTP service, known as a webhook.

### AlwaysAllow
AlwaysAllow mode allows all requests without any further authorization checks. 

### AlwaysDeny
AlwaysDeny mode denies all requests without any further authorization checks. This mode can be useful in highly secure environments where strict access control is critical, or in situations where authorization is not required at all.

### Configure Authorization Modes
Update the authorization-mode in apiserver. 
```yaml
cloud_user_p_8e31226b@k8s:~$ docker exec kind-control-plane cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep authorization-mode 
    - --authorization-mode=Node,RBAC
cloud_user_p_8e31226b@k8s:~$ 
```

## Clusterrole and Role Bindings 

### Role and RoleBinding

```yaml
cloud_user_p_8e31226b@k8s:~$ cat test-role.yaml
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: test
  name: testadmin
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: testadminbinding
  namespace: test
subjects:
- kind: ServiceAccount
  name: myaccount
  apiGroup: ""
roleRef:
  kind: Role
  name: testadmin
  apiGroup: ""
cloud_user_p_8e31226b@k8s:~$ kubectl create ns test 
namespace/test created
cloud_user_p_8e31226b@k8s:~$ kubectl create -f test-role.yaml 
role.rbac.authorization.k8s.io/testadmin created
rolebinding.rbac.authorization.k8s.io/testadminbinding created
cloud_user_p_8e31226b@k8s:~$
```
### Clusterrole and ClusterRoleBinding
Cluster roles do not belong to a namespace. This means the cluster role does not scope permission to a single namespace.

## Security Contexts 
In Kubernetes, a security context defines privileges for individual pods or containers. You can use security context to grant containers or pods permissions such as the right to access an external file or run in privileged mode.

## Network Policy 
This is Kubernetes assets that control the traffic between pods. Kubernetes network policy lets developers secure access to and from their applications. This is how we can restrict a user for access.



