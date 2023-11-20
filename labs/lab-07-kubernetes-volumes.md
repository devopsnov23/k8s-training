Kubernetes volumes offer a simple way to mount external storage to containers. This lab will test your knowledge of volumes as you provide storage to some containers according to a provided specification. This will allow you to practice what you know about using Kubernetes volumes.

1. Create a Pod that will interact with the host file system:
cloud_user_p_01431456@k8s:~$ vi maintanence-pod.yaml 

2. Enter in the first part of the basic YAML for a simple busybox Pod that outputs some data every five seconds to the host's disk:
apiVersion: v1
kind: Pod
metadata:
    name: maintenance-pod
spec:
    containers:
    - name: busybox
      image: busybox
      command: ['sh', '-c', 'while true; do echo Success! >> /output/output.txt; sleep 5; done']

3. Under the basic YAML, begin creating volumes, which should be level with the containers spec:
volumes:
- name: output-vol
  hostPath:
      path: /var/data

4. In the containers spec of the basic YAML, add a line for volume mounts:
volumeMounts:
- name: output-vol
  mountPath: /output

5. Check that the final maintenance-pod.yml file looks like this:
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

6. Save the file and exit by pressing the ESC key and using :wq.

7. Finish creating the Pod:
cloud_user_p_01431456@k8s:~$ kubectl create -f maintenance-pod.yml
pod/maintenance-pod created
cloud_user_p_01431456@k8s:~$

8. Make sure the Pod is up and running:
cloud_user_p_01431456@k8s:~$ kubectl get po -o wide 
NAME              READY   STATUS              RESTARTS   AGE   IP       NODE          NOMINATED NODE   READINESS GATES
maintenance-pod   0/1     ContainerCreating   0          19s   <none>   kind-worker   <none>           <none>
cloud_user_p_01431456@k8s:~$ kubectl get po -o wide 
NAME              READY   STATUS    RESTARTS   AGE   IP           NODE          NOMINATED NODE   READINESS GATES
maintenance-pod   1/1     Running   0          26s   10.244.1.2   kind-worker   <none>           <none>
cloud_user_p_01431456@k8s:~$

9. Look at the output to see whether the Pod setup was successful:
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


