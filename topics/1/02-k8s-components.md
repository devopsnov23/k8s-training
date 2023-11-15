Kubernetes Cluster mainly consists of Worker Machines called Nodes and a Control Plane. In a cluster, there is at least one worker node. The Kubectl CLI communicates with the Control Plane and Control Plane manages the Worker Nodes.   
   
## Kubernetes – Cluster Architecture   
As can be seen in the diagram below, Kubernetes has a client-server architecture and has master and worker nodes, with the master being installed on a single Linux system and the nodes on many Linux workstations.    
   
## Kubernetes Components   
Kubernetes is composed of a number of components, each of which plays a specific role in the overall system. These components can be divided into two categories:   
nodes: Each Kubernetes cluster requires at least one worker node, which is a collection of worker machines that make up the nodes where our container will be deployed.   
Control plane: The worker nodes and any pods contained within them will be under the control plane.    
   
## Control Plane Components   
It is basically a collection of various components that help us in managing the overall health of a cluster.  For example, if you want to set up new pods, destroy pods, scale pods, etc. Basically, 4 services run on Control Plane:   
   
## Kube-API server   
The API server is a component of the Kubernetes control plane that exposes the Kubernetes API. It is like an initial gateway to the cluster that listens to updates or queries via CLI like Kubectl. Kubectl communicates with API Server to inform what needs to be done like creating pods or deleting pods etc. It also works as a gatekeeper. It generally validates requests received and then forwards them to other processes. No request can be directly passed to the cluster, it has to be passed through the API Server.   
   
## Kube-Scheduler   
When API Server receives a request for Scheduling Pods then the request is passed on to the Scheduler. It intelligently decides on which node to schedule the pod for better efficiency of the cluster.   
   
## Kube-Controller-Manager   
The kube-controller-manager is responsible for running the controllers that handle the various aspects of the cluster’s control loop. These controllers include the replication controller, which ensures that the desired number of replicas of a given application is running, and the node controller, which ensures that nodes are correctly marked as “ready” or “not ready” based on their current state.   
   
## etcd    
It is a key-value store of a Cluster. The Cluster State Changes get stored in the etcd. It acts as the Cluster brain because it tells the Scheduler and other processes about which resources are available and about cluster state changes.   
   
## Node Components   
These are the nodes where the actual work happens. Each Node can have multiple pods and pods have containers running inside them. There are 3 processes in every Node that are used to Schedule and manage those pods.   
   
## Container runtime   
A container runtime is needed to run the application containers running on pods inside a pod. Example-> Docker   
   
## kubelet   
 kubelet interacts with both the container runtime as well as the Node. It is the process responsible for starting a pod with a container inside.   
   
## kube-proxy   
It is the process responsible for forwarding the request from Services to the pods. It has intelligent logic to forward the request to the right pod in the worker node   
   
