## Label and Selectors 

Labels and Selectors are the standard method to group things together in Kubernetes. We can filter the objects based on the criteria like class, kind, and functions.

- Labels are the properties attached to each item/object.
- Selector helps us to filter the items/objects which have labels attached to them.

We have n number of different type of objects in Kubernetes, like Pods, ReplicaSet, Deployments, Services, etc. By time when our infrastructure is increasing we will have 1000s of objects in our cluster.

And there are situations when you need a way to filter and view different objects by different categories. Such as group objects by their types or by application or by their functionality whatever it may be.

```yaml
apiVersion: v1
kind: ReplicaSet
metadata:
 name: simple-webapp
 labels:  ###labels we see here are the labels for replicaSet###
  app: app1
  function: front-end
 annotations:
  buildversion: 1.4  
spec:
 replicas: 3
 selector:
  matchLabels:
   app: App1   ####match label with the labels of pod###
 template:
  metadata:
   labels:    ###labels defined under template section are the labels configure on the pods### 
    app: app1
    function: front-end
  spec:
   containers:
   - name: simple-webapp
     image: nginx
```

In the replicaset definiation file, we can see labels defined in the 2 places. The labels on the Replicaset will be used if were configure some other objects to discover the ReplicaSet.

In order to connect the Replicaset to the Pod, we configured the selector field under the Replicaset specification to match the labels defines on the Pod.

A single label on the pod can work with Replicaset if its matches correctly. However if there are other pods with same labels, but with a different function then, we can specify all the labels to ensure the right pods discovered by the ReplicaSet.

It works same for other objects like a service, when a service is created it uses the selector defined in the service definiation file to match the lables set on the pods in the replicaSet definiation file.

```yaml
apiVersion: v1
kind: Service
metadata:
 name: frontendservice
spec:
 selector:
  app: app1    ###match selector with above pod label
 ports:
 - protocol: TCP
   port: 80
   targetport: 9376
```

