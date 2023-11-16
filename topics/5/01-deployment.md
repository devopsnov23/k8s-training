## Deployment 

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/d46949bd-28b3-4690-9135-9291bb06bad9)

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/2530fe97-9f1c-4984-8f1a-ca73f1bb4e9c)

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/4d5da8df-693f-404c-8f97-d1fc7054171f)

```yaml
cloud_user_p_bed41efd@kind:~$ cat nginx-deploy.yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      deploy: example
  template:
    metadata:
      labels:
        deploy: example
    spec:
      containers:
        - name: nginx
          image: nginx:1.7.9
cloud_user_p_bed41efd@kind:~$ kubectl create -f nginx-deploy.yaml 
deployment.apps/nginx-deployment created
cloud_user_p_bed41efd@kind:~$ 
```

```yaml
cloud_user_p_bed41efd@kind:~$ kubectl get deployments 
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           61s
cloud_user_p_bed41efd@kind:~$

cloud_user_p_bed41efd@kind:~$ kubectl get po 
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-569558bf55-5hktb   1/1     Running   0          99s
nginx-deployment-569558bf55-ccz7j   1/1     Running   0          99s
nginx-deployment-569558bf55-qvfwb   1/1     Running   0          99s
cloud_user_p_bed41efd@kind:~$ kubectl delete pod nginx-deployment-569558bf55-5hktb
pod "nginx-deployment-569558bf55-5hktb" deleted
cloud_user_p_bed41efd@kind:~$ kubectl get po 
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-569558bf55-ccz7j   1/1     Running   0          2m6s
nginx-deployment-569558bf55-q4bk5   1/1     Running   0          6s
nginx-deployment-569558bf55-qvfwb   1/1     Running   0          2m6s
cloud_user_p_bed41efd@kind:~$
```

### Scaling 

```yaml
cloud_user_p_bed41efd@kind:~$ kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   3/3     3            3           4m5s
cloud_user_p_bed41efd@kind:~$ kubectl scale deployment nginx-deployment --replicas=5
deployment.apps/nginx-deployment scaled
cloud_user_p_bed41efd@kind:~$ kubectl get po 
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-569558bf55-76k8p   1/1     Running   0          6s
nginx-deployment-569558bf55-ccz7j   1/1     Running   0          4m31s
nginx-deployment-569558bf55-l7mv5   1/1     Running   0          6s
nginx-deployment-569558bf55-q4bk5   1/1     Running   0          2m31s
nginx-deployment-569558bf55-qvfwb   1/1     Running   0          4m31s
cloud_user_p_bed41efd@kind:~$ kubectl scale deployment nginx-deployment --replicas=2
deployment.apps/nginx-deployment scaled
cloud_user_p_bed41efd@kind:~$ kubectl get po 
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-569558bf55-76k8p   1/1     Running   0          18s
nginx-deployment-569558bf55-qvfwb   1/1     Running   0          4m43s
cloud_user_p_bed41efd@kind:~$
```

### Rolling Updates 

Rolling Updates allow you to make changes to a deployment's pods at a controlled rate, gradually replacing old pods with new ones. This allows to update the pods without incurring downtime. Rollback can be done if an update causes issues. 

```yaml
cloud_user_p_bed41efd@kind:~$ kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     2            2           9m2s
cloud_user_p_bed41efd@kind:~$ kubectl edit deployment nginx-deployment
deployment.apps/nginx-deployment edited
cloud_user_p_bed41efd@kind:~$ kubectl get deployment
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     1            2           10m
cloud_user_p_bed41efd@kind:~$ kubectl rollout status deployment.v1.apps/nginx-deployment 
Waiting for deployment "nginx-deployment" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "nginx-deployment" rollout to finish: 1 old replicas are pending termination...
deployment "nginx-deployment" successfully rolled out
cloud_user_p_bed41efd@kind:~$
```

### Rollback 
```yaml
cloud_user_p_bed41efd@kind:~$ kubectl set image deployment/nginx-deployment nginx=nginx:broken
deployment.apps/nginx-deployment image updated
cloud_user_p_bed41efd@kind:~$ kubectl rollout status deployment.v1.apps/nginx-deployment 
Waiting for deployment "nginx-deployment" rollout to finish: 1 out of 2 new replicas have been updated...
^Ccloud_user_p_bed41efd@kind:~$ kubectl get po 
NAME                                READY   STATUS             RESTARTS   AGE
nginx-deployment-57d9555d49-g7sp8   0/1     ImagePullBackOff   0          51s
nginx-deployment-8695bbc87f-b2cn8   1/1     Running            0          4m52s
nginx-deployment-8695bbc87f-c9zs7   1/1     Running            0          4m21s
cloud_user_p_bed41efd@kind:~$
cloud_user_p_bed41efd@kind:~$ kubectl rollout history deployment/nginx-deployment 
deployment.apps/nginx-deployment 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
3         kubectl set image deployment/nginx-deployment nginx=nginx:broken --record=true

cloud_user_p_bed41efd@kind:~$ kubectl rollout undo deployment/nginx-deployment 
deployment.apps/nginx-deployment rolled back
cloud_user_p_bed41efd@kind:~$
cloud_user_p_bed41efd@kind:~$ kubectl get po 
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-8695bbc87f-b2cn8   1/1     Running   0          8m24s
nginx-deployment-8695bbc87f-c9zs7   1/1     Running   0          7m53s
cloud_user_p_bed41efd@kind:~$
```

