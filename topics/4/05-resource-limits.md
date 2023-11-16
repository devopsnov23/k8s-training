## Limits and Requests
Kubernetes defines Limits as the maximum amount of a resource to be used by a container. This means that the container can never consume more than the memory amount or CPU amount indicated. 

Requests, on the other hand, are the minimum guaranteed amount of a resource that is reserved for a container.

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/5cd4fabe-80ad-4a3c-be32-ebc68a7416eb)


```yaml
cloud_user_p_bed41efd@kind:~$ cat cpu-request-limit.yaml 
apiVersion: v1
kind: Pod
metadata:
  name: cpu-demo
  namespace: cpu-example
spec:
  containers:
  - name: cpu-demo-ctr
    image: vish/stress
    resources:
      limits:
        cpu: "1"
      requests:
        cpu: "0.5"
    args:
    - -cpus
    - "2"
cloud_user_p_bed41efd@kind:~$ kubectl create ns cpu-example 
namespace/cpu-example created
cloud_user_p_bed41efd@kind:~$ kubectl create -f cpu-request-limit.yaml 
pod/cpu-demo created
cloud_user_p_bed41efd@kind:~$ kubectl get pod cpu-demo --namespace=cpu-example
NAME       READY   STATUS    RESTARTS   AGE
cpu-demo   1/1     Running   0          14s
cloud_user_p_bed41efd@kind:~$ 

cloud_user_p_bed41efd@kind:~$ kubectl get pod cpu-demo --output=yaml --namespace=cpu-example
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: "2023-11-16T19:39:08Z"
  name: cpu-demo
  namespace: cpu-example
  resourceVersion: "2634"
  uid: 8578dd9a-3875-40dc-b69f-165195ffea8f
spec:
  containers:
  - args:
    - -cpus
    - "2"
    image: vish/stress
    imagePullPolicy: Always
    name: cpu-demo-ctr
    resources:
      limits:
        cpu: "1"
      requests:
        cpu: 500m
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-8bkht
      readOnly: true
...
...
$ 
```
