## Pods    
Pods are the smallest deployable units of computing that you can create and manage in Kubernetes.   
   
A Pod is a group of one or more containers, with shared storage and network resources, and a specification for how to run the containers   
   
simple-pod.yaml:   
```yaml   
apiVersion: v1   
kind: Pod   
metadata:   
  name: nginx   
spec:   
  containers:   
  - name: nginx   
    image: nginx:1.14.2   
    ports:   
    - containerPort: 80   
```

To create the Pod shown above, run the following command:   
kubectl apply -f simple-pod.yaml   
   
## Replicasets    
A ReplicaSet's purpose is to maintain a stable set of replica Pods running at any given time. As such, it is often used to guarantee the availability of a specified number of identical Pods.   
   
A ReplicaSet is defined with fields, including a selector that specifies how to identify Pods it can acquire, a number of replicas indicating how many Pods it should be maintaining, and a pod template specifying the data of new Pods it should create to meet the number of replicas criteria.   
   
frontend.yaml:   
```console
apiVersion: apps/v1   
kind: ReplicaSet   
metadata:   
  name: frontend   
  labels:   
    app: guestbook   
    tier: frontend   
spec:   
  # modify replicas according to your case   
  replicas: 3   
  selector:   
    matchLabels:   
      tier: frontend   
  template:   
    metadata:   
      labels:   
        tier: frontend   
    spec:   
      containers:   
      - name: php-redis   
        image: gcr.io/google_samples/gb-frontend:v3   
```
   
To create the replicaset, run the following command:  
```console
kubectl apply -f frontend.yaml   
```
To view the replicasets,    
```console
kubectl get replicaset
```
   
## Deployments    
A Deployment provides declarative updates for Pods and ReplicaSets.   
   
You describe a desired state in a Deployment, and the Deployment Controller changes the actual state to the desired state at a controlled rate. You can define Deployments to create new ReplicaSets, or to remove existing Deployments and adopt all their resources with new Deployments.   
   
nginx-deployment.yaml:   
```console
apiVersion: apps/v1   
kind: Deployment   
metadata:   
  name: nginx-deployment   
  labels:   
    app: nginx   
spec:   
  replicas: 3   
  selector:   
    matchLabels:   
      app: nginx   
  template:   
    metadata:   
      labels:   
        app: nginx   
    spec:   
      containers:   
      - name: nginx   
        image: nginx:1.14.2   
        ports:   
        - containerPort: 80   
```
```console   
kubectl apply -f nginx-deployment.yaml   
   
kubectl get deployments   
``` 
## Daemonsets    
A DaemonSet ensures that a copy of a Pod is running across a set of nodes in a Kubernetes cluster. DaemonSets are used to deploy system daemons such as log collectors and monitoring agents, which typically must run on every node. DaemonSets share similar functionality with ReplicaSets; both create Pods that are expected to be long-running services and ensure that the desired state and the observed state of the cluster match.   
   
daemonset.yaml:   
```console 
apiVersion: apps/v1   
kind: DaemonSet   
metadata:   
  name: fluentd-elasticsearch   
  labels:   
    k8s-app: fluentd-logging   
spec:   
  selector:   
    matchLabels:   
      name: fluentd-elasticsearch   
  template:   
    metadata:   
      labels:   
        name: fluentd-elasticsearch   
    spec:   
      containers:   
      - name: fluentd-elasticsearch   
        image: quay.io/fluentd_elasticsearch/fluentd:v2.5.2   
        resources:   
          limits:   
            memory: 200Mi   
          requests:   
            cpu: 100m   
            memory: 200Mi   
        volumeMounts:   
        - name: varlog   
          mountPath: /var/log   
      # it may be desirable to set a high priority class to ensure that a DaemonSet Pod   
      # preempts running Pods   
      # priorityClassName: important   
      terminationGracePeriodSeconds: 30   
      volumes:   
      - name: varlog   
        hostPath:   
          path: /var/log   
```
```console   
kubectl create -f daemonset.yaml   
```  
   
## Services    
   
In Kubernetes, a Service is a method for exposing a network application that is running as one or more Pods in your cluster.   
   
A key aim of Services in Kubernetes is that you don't need to modify your existing application to use an unfamiliar service discovery mechanism. You can run code in Pods, whether this is a code designed for a cloud-native world, or an older app you've containerized. You use a Service to make that set of Pods available on the network so that clients can interact with it.   

```console
kubectl create deployment my-nginx --image=nginx   
```   
public-nginx.yaml:   
```console
apiVersion: v1   
kind: Service   
metadata:   
  labels:   
    app: my-nginx   
  name: public-nginx   
spec:   
  ports:   
  - nodePort: 32001   
    port: 80   
    protocol: TCP   
    targetPort: 80   
  selector:   
    app: my-nginx   
  type: NodePort   
```
```console   
kubectl create -f public-nginx.yaml   
   
kubectl get pods,services | grep -z 32001   
   
curl http://$(uname -n):32001 | grep -C1 "successfully"   
```
  
## Namespaces    
In Kubernetes, namespaces provides a mechanism for isolating groups of resources within a single cluster. Names of resources need to be unique within a namespace, but not across namespaces.   
   
Namespaces are intended for use in environments with many users spread across multiple teams, or projects.   

```console
kubectl get namespace   
   
kubectl create ns project-1    
kubectl run nginx --image=nginx --namespace=project-1    
kubectl get pods -n project-1
```
