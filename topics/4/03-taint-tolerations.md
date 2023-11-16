## Taints and Tolerations 
Taints and tolerations are a mechanism that allows you to ensure that pods are not placed on inappropriate nodes. Taints are added to nodes, while tolerations are defined in the pod specification. When you taint a node, it will repel all the pods except those that have a toleration for that taint. A node can have one or many taints associated with it.

For example, most Kubernetes distributions will automatically taint the master nodes so that one of the pods that manages the control plane is scheduled onto them and not any other data plane pods deployed by users. This ensures that the master nodes are dedicated to run control plane pods.

A taint can produce three possible effects:

**NoSchedule** - The Kubernetes scheduler will only allow scheduling pods that have tolerations for the tainted nodes.
**PreferNoSchedule** - The Kubernetes scheduler will try to avoid scheduling pods that don’t have tolerations for the tainted nodes.
**NoExecute** - Kubernetes will evict the running pods from the nodes if the pods don’t have tolerations for the tainted nodes

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/4c41b77b-dd7b-44b6-8071-15d219a81d3f)


### Use Cases for Taints and Tolerations
- Dedicated Nodes
```yaml
kubectl taint nodes nodename dedicated=groupName:NoSchedule
```
- Nodes with Special Hardware
```yaml
kubectl taint nodes nodename special=true:NoSchedule
```

### Taint-Based Evictions
A taint with the NoExecute effect will evict the running pod from the node if the pod has no tolerance for the taint. The Kubernetes node controller will automatically add this kind of taint to a node in some scenarios so that pods can be evicted immediately and the node is “drained” (have all of its pods evicted). 

```yaml
root@e2e-73-175:~# kubectl get nodes -o=custom-columns=NodeName:.metadata.name,TaintKey:.spec.taints[*].key,TaintValue:.spec.taints[*].value,TaintEffect:.spec.taints[*].effect
NodeName             TaintKey                         TaintValue   TaintEffect
kind-control-plane   node-role.kubernetes.io/master   <none>       NoSchedule
kind-worker          <none>                           <none>       <none>
kind-worker2         <none>                           <none>       <none>
root@e2e-73-175:~#
```

From the output above, we noticed that the master nodes are already tainted by the Kubernetes installation so that no user pods land on them until intentionally configured by the user to be placed on master nodes by adding tolerations for those taints. We will now taint the worker so that only front-end pods can land on it.

```yaml
root@e2e-73-175:~# kubectl taint nodes kind-worker app=frontend:NoSchedule
node/kind-worker tainted
root@e2e-73-175:~#
```

The above taint has a key name app, with a value frontend, and has the effect of NoSchedule, which means that no pod will be placed on this node until the pod has defined a toleration for the taint.

Let’s try to deploy an app on the cluster without any toleration configured in the app deployment specification.

```yaml
root@e2e-73-175:~# kubectl create ns frontend
namespace/frontend created
root@e2e-73-175:~#
root@e2e-73-175:~#  kubectl run nginx --image=nginx --namespace frontend
pod/nginx created
root@e2e-73-175:~#
root@e2e-73-175:~# kubectl get pods -n frontend
NAME    READY   STATUS    RESTARTS   AGE
nginx   1/1     Running   0          21s
root@e2e-73-175:~# kubectl get pods -n frontend -o wide
NAME    READY   STATUS    RESTARTS   AGE   IP           NODE           NOMINATED NODE   READINESS GATES
nginx   1/1     Running   0          31s   10.244.2.2   **kind-worker2**   <none>           <none>
root@e2e-73-175:~#
```

Lets taint the other worker node too 

```yaml
root@e2e-73-175:~# kubectl taint nodes kind-worker2 app=frontend:NoSchedule
node/kind-worker2 tainted
root@e2e-73-175:~#
```

And try to deploy again 
```yaml
root@e2e-73-175:~# kubectl run nginx-2 --image=nginx -n frontend
pod/nginx-2 created
root@e2e-73-175:~# kubectl get pods -n frontend -o wide
NAME      READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
nginx     1/1     Running   0          5m35s   10.244.2.2   kind-worker2   <none>           <none>
nginx-2   0/1     Pending   0          8s      <none>       <none>         <none>           <none>
root@e2e-73-175:~# kubectl get pods -n frontend -o wide
NAME      READY   STATUS    RESTARTS   AGE     IP           NODE           NOMINATED NODE   READINESS GATES
nginx     1/1     Running   0          5m48s   10.244.2.2   kind-worker2   <none>           <none>
nginx-2   0/1     Pending   0          21s     <none>       <none>         <none>           <none>
root@e2e-73-175:~# kubectl get pods -n frontend -o wide
NAME      READY   STATUS    RESTARTS   AGE    IP           NODE           NOMINATED NODE   READINESS GATES
nginx     1/1     Running   0          6m3s   10.244.2.2   kind-worker2   <none>           <none>
nginx-2   0/1     Pending   0          36s    <none>       <none>         <none>           <none>
root@e2e-73-175:~#
```

Lets check why the nginx-2 is still pending. 
```yaml
root@e2e-73-175:~# kubectl get pods -n frontend
NAME      READY   STATUS    RESTARTS   AGE
nginx     1/1     Running   0          7m45s
nginx-2   0/1     Pending   0          2m18s
root@e2e-73-175:~# kubectl get events -n frontend
LAST SEEN   TYPE      REASON             OBJECT        MESSAGE
34s         Warning   **FailedScheduling   pod/nginx-2   0/3 nodes are available: 1 node(s) had taint {node-role.kubernetes.io/master: }, that the pod didn't tolerate, 2 node(s) had taint {app: frontend}, that the pod didn't tolerate.**
9m37s       Normal    Scheduled          pod/nginx     Successfully assigned frontend/nginx to kind-worker2
9m37s       Normal    Pulling            pod/nginx     Pulling image "nginx"
9m28s       Normal    Pulled             pod/nginx     Successfully pulled image "nginx" in 8.642402422s
9m28s       Normal    Created            pod/nginx     Created container nginx
9m28s       Normal    Started            pod/nginx     Started container nginx
root@e2e-73-175:~#


```

Now let us apply toleration to nginx-2 pod. 

```yaml
root@e2e-73-175:~# kubectl edit po nginx-2 -n frontend
pod/nginx-2 edited
root@e2e-73-175:~# kubectl get po nginx-2 -n frontend -o yaml
apiVersion: v1
kind: Pod
...
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: nginx-2
    resources: {}
...
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  - **effect: NoSchedule**
    **key: app**
    **operator: Equal**
    **value: frontend**
  volumes:
  - name: kube-api-access-rl4wd
    projected:
      defaultMode: 420
      sources:
...
...
#
root@e2e-73-175:~# kubectl get pods -n frontend
NAME      READY   STATUS    RESTARTS   AGE
nginx     1/1     Running   0          20m
nginx-2   1/1     Running   0          14m
root@e2e-73-175:~#
```
