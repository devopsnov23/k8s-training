# Kubernetes Storage 

### Container Storage

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/a6e31865-b301-488b-914b-0fc66443ea1d)

### Volumes 

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/9da7a87b-193d-464f-91a7-6af2dc30a704)



![image](https://github.com/devopsnov23/k8s-training/assets/150913274/2f20b624-d217-49a4-8aa3-f2e340b78938)

### Persistent Volume

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/0c1f0bd4-3b75-4c90-b6e8-f3ee6228b4ee)


### Volume Types 
- NFS
- Cloud Storage
- ConfigMaps and Secrets
- A simple directory on the K8s node

### Managing Container Storage with Kubernetes Volumes

```yaml
cloud_user_p_01431456@k8s:~$ cat maintenance-pod.yml
apiVersion: v1
kind: Pod
metadata:
    name: maintenance-pod
spec:
    containers:
    - name: busybox
      image: busybox
      command: ['sh', '-c', 'while true; do echo Success! >> /output/output.txt; sleep 5; done']

      volumeMounts:
      - name: output-vol
        mountPath: /output

    volumes:
    - name: output-vol
      hostPath:
        path: /var/data
cloud_user_p_01431456@k8s:~$ kubectl create -f maintenance-pod.yml
pod/maintenance-pod created
cloud_user_p_01431456@k8s:~$ kubectl get po -o wide 
NAME              READY   STATUS              RESTARTS   AGE   IP       NODE          NOMINATED NODE   READINESS GATES
maintenance-pod   0/1     ContainerCreating   0          19s   <none>   kind-worker   <none>           <none>
cloud_user_p_01431456@k8s:~$ kubectl get po -o wide 
NAME              READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
maintenance-pod   1/1     Running   0          26s   10.244.1.2   kind-worker   <none>           <none>
cloud_user_p_01431456@k8s:~$ docker exec -it kind-worker sh 
# cat /var/data/output.txt
Success!
Success!
Success!
Success!
Success!
Success!
Success!
Success!
# exit
cloud_user_p_01431456@k8s:~$
```

### Multi-Container Pod That Shares Data Between Containers Using a Volume

```yaml
cloud_user_p_01431456@k8s:~$ cat shared-data-pod.yml
---
apiVersion: v1
kind: Pod
metadata:
    name: shared-data-pod
spec:
    containers:
    - name: busybox1
      image: busybox
      command: ['sh', '-c', 'while true; do echo Success! >> /output/output.txt; sleep 5; done']
      volumeMounts:
      - name: shared-vol
        mountPath: /output
    - name: busybox2
      image: busybox
      command: ['sh', '-c', 'while true; do cat /input/output.txt; sleep 5; done']
      volumeMounts:
      - name: shared-vol
        mountPath: /input
    volumes:
    - name: shared-vol
      emptyDir: {}
cloud_user_p_01431456@k8s:~$ kubectl create -f shared-data-pod.yml
pod/shared-data-pod created
cloud_user_p_01431456@k8s:~$ kubectl get pods 
NAME              READY   STATUS    RESTARTS   AGE
maintenance-pod   1/1     Running   0          4m43s
shared-data-pod   2/2     Running   0          7s
cloud_user_p_01431456@k8s:~$ kubectl logs shared-data-pod -c busybox2
Success!
Success!
Success!
Success!
Success!
Success!
Success!
Success!
Success!
Success!
cloud_user_p_01431456@k8s:~$ 
```

### Persistent Volume

Create PV 
```yaml
cloud_user_p_01431456@k8s:~$ cat localdisk.yml 
apiVersion: storage.k8s.io/v1 
kind: StorageClass 
metadata: 
  name: localdisk 
provisioner: kubernetes.io/no-provisioner
allowVolumeExpansion: true
cloud_user_p_01431456@k8s:~$ kubectl create -f localdisk.yml
storageclass.storage.k8s.io/localdisk created
cloud_user_p_01431456@k8s:~$ cat host-pv.yml 
kind: PersistentVolume 
apiVersion: v1 
metadata: 
   name: host-pv 
spec: 
   storageClassName: localdisk
   persistentVolumeReclaimPolicy: Recycle 
   capacity: 
      storage: 1Gi 
   accessModes: 
      - ReadWriteOnce 
   hostPath: 
      path: /var/output
cloud_user_p_01431456@k8s:~$ kubectl create -f host-pv.yml
persistentvolume/host-pv created
cloud_user_p_01431456@k8s:~$ kubectl get pv 
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
host-pv   1Gi        RWO            Recycle          Available           localdisk               8s
cloud_user_p_01431456@k8s:~$
```

Create PVC 
```yaml
cloud_user_p_01431456@k8s:~$ cat host-pvc.yml
apiVersion: v1 
kind: PersistentVolumeClaim 
metadata: 
   name: host-pvc 
spec: 
   storageClassName: localdisk 
   accessModes: 
      - ReadWriteOnce 
   resources: 
      requests: 
         storage: 100Mi
cloud_user_p_01431456@k8s:~$ kubectl create -f host-pvc.yml
persistentvolumeclaim/host-pvc created
cloud_user_p_01431456@k8s:~$ kubectl get pv
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM              STORAGECLASS   REASON   AGE
host-pv   1Gi        RWO            Recycle          Bound    default/host-pvc   localdisk               88s
cloud_user_p_01431456@k8s:~$ kubectl get pvc
NAME       STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
host-pvc   Bound    host-pv   1Gi        RWO            localdisk      11s
cloud_user_p_01431456@k8s:~$ 
```

Create a Pod That Uses a PersistentVolume for Storage
```yaml
cloud_user_p_01431456@k8s:~$ cat pv-pod.yml
apiVersion: v1
kind: Pod 
metadata: 
   name: pv-pod 
spec: 
   containers: 
   - name: busybox 
     image: busybox 
     command: ['sh', '-c', 'while true; do echo Success! > /output/success.txt; sleep 5; done'] 
     volumeMounts: 
     - name: pv-storage 
       mountPath: /output 
   volumes:
   - name: pv-storage
     persistentVolumeClaim:
       claimName: host-pvc

cloud_user_p_01431456@k8s:~$ kubectl create -f pv-pod.yml
pod/pv-pod created
cloud_user_p_01431456@k8s:~$ kubectl get pods 
NAME     READY   STATUS    RESTARTS   AGE
pv-pod   1/1     Running   0          12s
cloud_user_p_01431456@k8s:~$ kubectl get pods -o wide 
NAME     READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
pv-pod   1/1     Running   0          29s   10.244.1.3   kind-worker   <none>           <none>
cloud_user_p_01431456@k8s:~$ docker exec  kind-worker cat /var/output/success.txt
Success!
cloud_user_p_01431456@k8s:~$
```