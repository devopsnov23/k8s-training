## Services    
   
In Kubernetes, a Service is a method for exposing a network application that is running as one or more Pods in your cluster.   
   
A key aim of Services in Kubernetes is that you don't need to modify your existing application to use an unfamiliar service discovery mechanism. You can run code in Pods, whether this is a code designed for a cloud-native world, or an older app you've containerized. You use a Service to make that set of Pods available on the network so that clients can interact with it.   

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/88775729-8590-453e-b07a-7262ba6a225f)

```console
kubectl create deployment my-nginx --image=nginx   
```   
public-nginx.yaml:   
```console
apiVersion: v1   
kind: Service   
metadata:   
  labels:   
    app: my-nginx   
  name: public-nginx   
spec:   
  ports:   
  - nodePort: 32001   
    port: 80   
    protocol: TCP   
    targetPort: 80   
  selector:   
    app: my-nginx   
  type: NodePort   
```
```console   
kubectl create -f public-nginx.yaml   
   
kubectl get pods,services | grep -z 32001   
   
curl http://$(uname -n):32001 | grep -C1 "successfully"   
```

