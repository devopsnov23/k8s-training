## nodeSelector
NodeSelector is the early Kubernetes feature designed for manual Pod scheduling. The basic idea behind the nodeSelector is to allow a Pod to be scheduled only on those nodes that have label(s) identical to the label(s) defined in the nodeSelector. The latter are key-value pairs that can be specified inside the PodSpec.

Applying nodeSelector to the Pod involves several steps. We first need to assign a label to some node that will be later used by the nodeSelector . 

```yaml
cloud_user_p_bed41efd@kind:~$ kubectl get nodes --show-labels
NAME                 STATUS     ROLES                  AGE   VERSION   LABELS
kind-control-plane   Ready      control-plane,master   45s   v1.23.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-control-plane,kubernetes.io/os=linux,node-role.kubernetes.io/control-plane=,node-role.kubernetes.io/master=,node.kubernetes.io/exclude-from-external-load-balancers=
kind-worker          NotReady   <none>                 10s   v1.23.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-worker,kubernetes.io/os=linux
kind-worker2         Ready      <none>                 10s   v1.23.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-worker2,kubernetes.io/os=linux
cloud_user_p_bed41efd@kind:~$
```

Add label to a node 
```yaml
cloud_user_p_bed41efd@kind:~$ kubectl label nodes kind-worker2 disktype=ssd
node/kind-worker2 labeled
cloud_user_p_bed41efd@kind:~$ kubectl get nodes --show-labels | grep disktype
kind-worker2         Ready    <none>                 50s   v1.23.4   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,disktype=ssd,kubernetes.io/arch=amd64,kubernetes.io/hostname=kind-worker2,kubernetes.io/os=linux
cloud_user_p_bed41efd@kind:~$ 
```

In order to assign a Pod to the node with the label we just added, you need to specify a nodeSelector field in the PodSpec. 

```yaml
cloud_user_p_bed41efd@kind:~$ cat test-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: httpd
  labels:
    env: prod
spec:
  containers:
  - name: httpd
    image: httpd
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
cloud_user_p_bed41efd@kind:~$ kubectl create -f test-pod.yaml 
pod/httpd created
cloud_user_p_bed41efd@kind:~$ kubectl get po 
NAME    READY   STATUS    RESTARTS   AGE
httpd   1/1     Running   0          17s
cloud_user_p_bed41efd@kind:~$ kubectl get po -o wide 
NAME    READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
httpd   1/1     Running   0          24s   10.244.1.2   kind-worker2   <none>           <none>
cloud_user_p_bed41efd@kind:~$ 
```

## Node Affinity
Node affinity allows scheduling Pods to specific nodes. There are a number of use cases for node affinity, including the following:

- Spreading Pods across different availability zones to improve resilience and availability of applications in the cluster 
- Allocating nodes for memory-intensive Pods.

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/5eae8d97-6776-4493-9af7-179c63230f35)


Example 
```yaml
cloud_user_p_bed41efd@kind:~$ cat > affinity-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: with-node-affinity
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/e2e-az-name
            operator: In
            values:
            - e2e-az1
            - e2e-az2
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: custom-key
            operator: In
            values:
            - custom-value
  containers:
  - name: with-node-affinity
    image: k8s.gcr.io/pause:2.0
cloud_user_p_bed41efd@kind:~$ kubectl label nodes kind-worker kubernetes.io/e2e-az-name=e2e-az1
node/kind-worker labeled
cloud_user_p_bed41efd@kind:~$ kubectl create -f affinity-pod.yaml 
pod/with-node-affinity created
cloud_user_p_bed41efd@kind:~$ kubectl get po -o wide | grep with-node-affinity
with-node-affinity   1/1     Running   0          38s     10.244.2.2   kind-worker    <none>           <none>
cloud_user_p_bed41efd@kind:~$ 
```
