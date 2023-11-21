PersistentVolumes provide a way to treat storage as a dynamic resource in Kubernetes. This lab will allow you to demonstrate your knowledge of PersistentVolumes. You will mount some persistent storage to a container using a PersistentVolume and a PersistentVolumeClaim.

## Create a PersistentVolume That Allows Claim Expansion
 
1. Create a custom Storage Class by using vi localdisk.yml.
2. Define the Storage Class by using:
```yaml
apiVersion: storage.k8s.io/v1 
kind: StorageClass 
metadata: 
  name: localdisk 
provisioner: kubernetes.io/no-provisioner
allowVolumeExpansion: true
```
3. Save and exit the file
4. Finish creating the Storage Class by using kubectl create -f localdisk.yml
```yaml
cloud_user_p_01431456@k8s:~$ kubectl create -f localdisk.yml
storageclass.storage.k8s.io/localdisk created
cloud_user_p_01431456@k8s:~$
```
5. Create the PersistentVolume 
```yaml
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
cloud_user_p_01431456@k8s:~$
```
6. Check the status of the PersistenVolume by using kubectl get pv.
```yaml
cloud_user_p_01431456@k8s:~$ kubectl get pv 
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
host-pv   1Gi        RWO            Recycle          Available           localdisk               8s
cloud_user_p_01431456@k8s:~$
```

## Create a PersistentVolumeClaim
1. Start creating a PersistentVolumeClaim for the PersistentVolume to bind to by using vi host-pvc.yml.
2. Define the PersistentVolumeClaim with a size of 100Mi by using:
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
cloud_user_p_01431456@k8s:~$
```
3. Save and exit the file
4. Finish creating the PersistentVolumeClaim by using kubectl create -f host-pvc.yml.
```yaml
cloud_user_p_01431456@k8s:~$ kubectl create -f host-pvc.yml
persistentvolumeclaim/host-pvc created
cloud_user_p_01431456@k8s:~$
```  
7. Check the status of the PersistentVolume and PersistentVolumeClaim to verify that they have been bound:
```yaml
cloud_user_p_01431456@k8s:~$ kubectl get pv
NAME      CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM              STORAGECLASS   REASON   AGE
host-pv   1Gi        RWO            Recycle          Bound    default/host-pvc   localdisk               88s
cloud_user_p_01431456@k8s:~$ kubectl get pvc
NAME       STATUS   VOLUME    CAPACITY   ACCESS MODES   STORAGECLASS   AGE
host-pvc   Bound    host-pv   1Gi        RWO            localdisk      11s
cloud_user_p_01431456@k8s:~$
```

## Create a Pod That Uses a PersistentVolume for Storage
1. Create a Pod that uses the PersistentVolumeClaim by using vi pv-pod.yml.
2. Define the Pod by using:
```yaml
apiVersion: v1 
kind: Pod 
metadata: 
   name: pv-pod 
spec: 
   containers: 
      - name: busybox 
        image: busybox 
        command: ['sh', '-c', 'while true; do echo Success! > /output/success.txt; sleep 5; done']
```
3. Mount the PersistentVolume to the /output location by adding the following, which should be level with the containers spec in terms of indentation:
```yaml
volumes: 
  - name: pv-storage 
    persistentVolumeClaim: 
       claimName: host-pvc
```
4. In the containers spec, below the command, set the list of volume mounts by using:
```yaml
volumeMounts: 
  - name: pv-storage 
    mountPath: /output
```
5. Save and exit the file
6. The final version of the file should look like below:
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

cloud_user_p_01431456@k8s:~$
```
7. Finish creating the Pod by using kubectl create -f pv-pod.yml.
```yaml
cloud_user_p_01431456@k8s:~$ kubectl create -f pv-pod.yml
pod/pv-pod created
cloud_user_p_01431456@k8s:~$
```
8. Check that the Pod is up and running by using kubectl get pods.
```yaml
cloud_user_p_01431456@k8s:~$ kubectl get pods 
NAME     READY   STATUS    RESTARTS   AGE
pv-pod   1/1     Running   0          12s
cloud_user_p_01431456@k8s:~$ kubectl get pods -o wide 
NAME     READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
pv-pod   1/1     Running   0          29s   10.244.1.3   kind-worker   <none>           <none>
cloud_user_p_01431456@k8s:~$
```
9. If you wish, you can log in to the worker node and verify the output data by using
```yaml
cloud_user_p_01431456@k8s:~$ docker exec  kind-worker cat /var/output/success.txt
Success!
cloud_user_p_01431456@k8s:~$







