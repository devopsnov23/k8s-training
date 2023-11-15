Kubernetes also known as K8s was built by Google based on their experience running containers in production. It is now an open-source project and is arguably one of the best and most popular container orchestration technologies out there. We will try to understand Kubernetes at a high level.   
   
To understand Kubernetes, we must first understand two things – Container and Orchestration. Once we get familiarized with both of these terms we would be in a position to understand what kubernetesis capable of. We will start looking at each of these next.   
   
### What are containers?   
Containers make it possible for an application to run consistently and reliably, regardless of the operating system or infrastructure environment. Containers do this by bundling up everything a service needs to run — code, runtime, system tools, system libraries and settings — creating a portable, standalone, executable package.   
   
### What is a container used for?   
Containers represent the future of compute — alongside technologies like DevOps, cloud native, AI and machine learning. Common use cases include:   
   
* Modernizing existing applications in the cloud   
* Creating new applications that maximize the benefits of containers   
* Isolating, deploying, scaling and supporting microservices and distributed apps   
* Boosting DevOps efficiency/effectiveness through streamlined build/test/deployment   
* Providing developers with consistent production environments, isolated from other applications and processes   
* Simplifying and accelerating repetitive functions   
* Facilitating hybrid and multicloud computing environments, since containers are able to run consistently anywhere   
   
### What is containerization?   
Containerization — the act of creating a container — involves pulling out just the application/service you need to run, along with its dependencies and configuration, and abstracting it from the operating system and the underlying infrastructure. The resulting container image can then be run on any container platform. Multiple containers can be run on the same host and share the same OS with other containers, each running isolated processes within its own secured space. Because containers share the base OS, the result is being able to run each container using significantly fewer resources than if each was a separate virtual machine (VM).   
   
### What is container orchestration?   
If you have just a handful of containers and two or three applications, container orchestration might not be necessary. But once the numbers grow, things become complicated. Container orchestration from Kubernetes makes it possible to deploy, scale and manage thousands of containerized applications, automatically.   
   
### Benefits of Kubernetes container orchestration include:   
   
* Service discovery and load balancing   
* Automatically mount storage systems of your choice   
* Automated rollouts and rollbacks   
* Optimal use of resources   
* Self-healing Kubernetes (restart failed containers; kill those that don’t respond to user-defined health checks)   
* Store and manage sensitive information   
* Deploy and update configurations without rebuilding container images   
   
### What are the main container tools and technologies?   
Docker and Kubernetes are the big names in the container space. Docker is an open source container platform. Kubernetes is the most popular option for container orchestration — although alternatives exist, such as Docker Swarm and VMware Tanzu. Major cloud providers — including AWS, Google and Microsoft Azure — offer containers as a service (CaaS) products as well.   
   
### When are containers the best option and when should you consider something different?   
Containers are a great option if you’re building a new application from scratch, are looking to apply a microservices-based architecture, or are looking for an ultra-portable, build-once-deploy-anywhere solution. But what about your existing, monolithic applications?   
   
Just as some physical machines don’t translate to virtual machines, applications that demand a lot of resources might not be good candidates for containerization. To make a CPU and RAM hungry application into a container, you’d need to break up how it works. This would require development time and money for little or no benefit and therefore would not be justified.   
   
   
   
   
