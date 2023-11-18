# Troubleshooting 

## Determining a Troubleshooting Strategy

Every K8s command follows the below path. 

1. Kubectl
2. API server
3. Etcd
4. Scheduler
5. Kubelet
6. Execute command

After kubectl run or kubectl create, the resources are written to etcd database.
Next, the scheduler will look up a node eligible to run the application. 
After finding the eligible node, the Pod image is fetched. 
Next, the pod container is started and runs its entrypoint application. 
Based on the success or failure of the entrypoint application, the pod restartpolicy is applied to determine further action. 

Hence it would be useful to check the error based on this path. 

## Troubleshooting Application Faliure 
An application can make use of various objects like: 
- Pods
- Services
- Secrets
- ConfigMaps
- Roles,RoleBindings
- Networking

If one of these does npt work properly. the application can behave unexpectedly. 

## Troubleshooting Application Failure 

A Pod will go through different states:
- Pending
- Running
- Completed
- Failed
- CrashLoopbackOff
- Unknown

Use **kubectl** **get** **pods** to get the pod status.
Use **kubectl** **describe** to investigate the application state. 
Use **kubectl** **logs** to investigate application logs. 

## Analyzing Pod Access Issues 
- To access an application, a service is used to load balance between available pods.
- To connect to the backend pods, the service is using a selector label that matches a pod label.
- If service dont work as expected, check the labels first.
- Use **kubectl** **get** **endpoints** to check services and corresponding pod endpoints.

## Monitor Cluster Event Logs 
- Use **kubectl** **get** **events** provides an overview of cluster-wide events.
- **kubectl** **get** **events** **-o** **wide** provides more details.
- Use **kubectl** **describe** to investigate the application state.

## Troubleshooting Authentication Problems 
- Use **kubectl** **config** **view** to check the contents of kubeconfig.
- For additional authorization based problems, use **kubectl** **auth** **can-i**:
**kubectl** **auth** **can-i** **create** **pods** 

## Troubleshooting Cluster Nodes 
- Use **kubectl** **cluster-info** for a generic impression of cluster health.
- Use **kubectl** **cluster-info** **dump** for detailed information coming from all the cluster log files.
- **kubectl** **get** **nodes** will give a generic overview of node health.
- **kubectl** **get** **pods** **-n** **kube-system** shows kubernetes core services running on the control node.
- **kubectl** **describe** **node** **<nodename>** shows detailed information about nodes.
- **sudo** **systemctl** **status** **kubelet** shows status of kubelet.
- The kube-proxy pods are running to ensure connectivity with worker nodes, use **kubectl** **get** **pods** **-n** **kube-system** for an overview.





