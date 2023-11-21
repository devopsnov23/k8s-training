# Kubernetes Storage 

### Container Storage

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/a6e31865-b301-488b-914b-0fc66443ea1d)

### Volumes 

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/9da7a87b-193d-464f-91a7-6af2dc30a704)



![image](https://github.com/devopsnov23/k8s-training/assets/150913274/2f20b624-d217-49a4-8aa3-f2e340b78938)

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

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/0c1f0bd4-3b75-4c90-b6e8-f3ee6228b4ee)

A persistent volume (PV) is a piece of storage in the Kubernetes cluster, while a persistent volume claim (PVC) is a request for storage.

#### Capacity
When creating a PV, you indicate its storage size in the Capacity attribute. In the example below, you are creating a PV of 1 gibibytes.

#### Access Modes
There are currently four access modes for PVs in Kubernetes:

- ReadWriteOnce: This allows only a single node to access the volume in read-write mode. Furthermore, all pods in that single node can read and write to such volumes.
- ReadWriteMany: Multiple nodes can read and write to the volume.
- ReadOnlyMany: This means that the volume will be in a read-only mode and accessible by multiple nodes.
- ReadWriteOncePod: Only a single pod can gain access to the volume.

#### StorageClassName
The storageClassName is the name of the storage class that will bind the PV to the user’s PVC. When a developer needs storage, they request it by creating a PVC.

#### Provisioner
The provisioner determines the volume plug-in used by the storageClass. Several plug-ins such as AWS EBS and GCE PD are available for different storage providers.

#### Persistent Volume Claims
A PersistentVolumeClaim (PVC) is a request for storage by a user. 

#### Reclaiming
Once you are done with a PV usage, you can free it up for other developers in the cluster to use by deleting the PVC object. The reclaim policy defined in the PV informs the cluster of what to do after Kubernetes unbinds it from a PVC. The retain policy attribute can have one of the following values: Retained, Recycled, or Deleted.

#### Expanding Persistent Volumes Claims
There might be an scenarios where your application might require a larger volume, especially when it already exceeds the capacity limit. To increase the storage, edit the PVC object and specify a larger capacity than you need.

It is important to note that you shouldn’t directly edit the capacity of the PV, but rather the PVC.


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
