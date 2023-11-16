## Kubernetes Manual Scheduling
The Kubernetes Scheduler is a core component of Kubernetes. In this tutorial we will discuss about different ways of Kubernetes manual scheduling a POD on a node.

What you do when you don’t have a scheduler in your cluster? You probably don’t want to rely on built in scheduler and instead want to schedule the PODs yourself.

So, how exactly does a scheduler work in the back end. Lets start with the simple POD definition.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels: 
    app: nginx

spec:
  containers:
    - name: nginx
      image: nginx
      ports
        - containerPort: 8080
```

Every POD has a field called nodeName that by default is not set. Kubernetes will create this field automatically.

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/d3709ab6-600b-4982-acf8-3195add99450)


The scheduler goes through the all PODs and looks for those that don’t have this property set. Those are the candidates for the scheduling. It then identifies the right node for the POD by running the scheduling the algorithm. Once identified, it schedules the POD on the node by setting the nodeName property to the name of the node by creating the binding object.

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/9cbedb51-7f97-42f3-af39-6df47c36d487)


```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels: 
    app: nginx

spec:
  containers:
    - name: nginx
      image: nginx
      ports
        - containerPort: 8080
  nodeName: node02
```

### No Scheduler
If there is no scheduler to monitor and schedule a node what happens? The pods continue to the in a pending stage.

```yaml 
$ kubectl get pods
NAME            READY   STATUS      RESTARTS   AGE
nginx           0/1     Pending        0       12s
```

So what can we do about it. We can manually assign the PODs to nodes yourself.

Without a scheduler the easiest way to schedule a POD is to simply set the nodeName field to the name of the node in your POD specification file while creating the POD. The POD then gets assigned to the specified node.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels: 
    app: nginx

spec:
  containers:
    - name: nginx
      image: nginx
      ports
        - containerPort: 8080
  nodeName: node02

$ kubectl get pods
NAME     READY   STATUS      RESTARTS   AGE   IP             NODE
nginx    1/1     Running     0          12s   10.40.0.15     node02
```

