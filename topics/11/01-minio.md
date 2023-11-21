## Minio 

MinIO is a high-performance object storage system. It is designed to be an alternative to cloud-native storage systems. In fact, its API is fully compatible with Amazon S3.

MinIO was designed from the beginning to be a fully compatible alternative to Amazon’s S3 storage API. They claim to be the most compatible S3 alternative while also providing comparable performance and scalability.

MinIO also provides a variety of deployment options. It can run as a native application on most popular architectures and can also be deployed as a containerized application using Docker or Kubernetes.

Additionally, MinIO is open-source software. Organizations are free to use it under the terms of the AGPLv3 license. For larger enterprises, paid subscriptions with dedicated support are also available.

Because of its S3 API compatibility, ability to run in a variety of deployments, and open-source nature, MinIO is a great tool for development and testing, as well as DevOps scenarios.

### How Object Storage Works
The concept of object storage is similar to that of a standard Unix file system, but instead of directories and files, we use buckets and objects.

Buckets can be nested into a hierarchy just like directories, and objects can be thought of as just a collection of bytes. Those collections can be arbitrary byte arrays or normal files like images, PDFs, and more.

An example object storage system might look like:

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/511aa593-a808-4edd-a5a4-33c80a5e59d5)

And just like directories and files, buckets and objects can have permissions. This allows fine-grained access control over data, especially in large organizations with many users.

### Minio Deployment

As mentioned earlier, MinIO is available for just about every platform. There are standalone installers for Windows, Linux, and MacOS. For development and testing purposes, however, the easiest way to get started is by using the containerized distribution.

Lets run a deployment of minio in Kubernetes. 

```yaml
cloud_user_p_d9227775@cloudshell:~$ cat minio-dev.yaml 
# Deploys a new Namespace for the MinIO Pod
apiVersion: v1
kind: Namespace
metadata:
  name: minio-dev # Change this value if you want a different namespace name
  labels:
    name: minio-dev # Change this value to match metadata.name
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
  namespace: minio-dev
  labels:
    app: minio
spec:
  replicas: 1
  template:
    metadata:
      name: minio
      labels:
        app: minio
    spec:
      volumes:
        - name: data
          emptyDir:
            sizeLimit: 100Mi
      containers:
        - name: minio
          image: quay.io/minio/minio:latest
          imagePullPolicy: IfNotPresent
          livenessProbe:
            httpGet:
              path: /minio/health/live
              port: 9000
            initialDelaySeconds: 120
            periodSeconds: 20
          readinessProbe:
            httpGet:
              path: /minio/health/ready
              port: 9000
            initialDelaySeconds: 120
            periodSeconds: 20

          volumeMounts:
            - mountPath: /data
              name: data
          command:
            - /bin/bash
            - -c
          args:
              - minio server /data --console-address :9090
      restartPolicy: Always
  selector:
    matchLabels:
      app: minio
---
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: minio-dev
spec:
  selector:
    app: minio
  ports:
    - port: 9090
      name: console
    - port: 9000
      name: s3
  type: LoadBalancer 
cloud_user_p_d9227775@cloudshell:~$
```

### Working with MinIO

There are a number of different ways to interact with the MinIO server and manage buckets and objects. Below, we will take a look at them all.

#### The MinIO Client
The MinIO client provides identical commands to Unix file management commands, such as cp and ls, but is designed for both local and remote storage systems. It’s fully compatible with AWS S3, and its syntax mimics that of the AWS client tool.

Installation 
```yaml
curl https://dl.min.io/client/mc/release/linux-amd64/mc \
  --create-dirs \
  -o $HOME/minio-binaries/mc

chmod +x $HOME/minio-binaries/mc
export PATH=$PATH:$HOME/minio-binaries/

mc --help
```

Most of these sub-commands work on both local file systems and cloud storage. For example, we can use the following command sequence to create new a new bucket, copy a file into that bucket, move the object between buckets, then remove a bucket:
```yaml
$ mc mb user1
$ mc cp ~/Resume.pdf prattm
$ mc mb user2
$ mc cp user1/Resume.pdf user2
$ mc rb user1
$ mc ls user2
```

#### The MinIO Console
Another way to manage data in a MinIO deployment is with the web-based admin console. With the containerized deployment, we start by opening the address http://127.0.0.1:9001 in a web browser. We log in using the default credentials of minioadmin / minioadmin.

From there, we can create our first bucket:

![image](https://github.com/devopsnov23/k8s-training/assets/150913274/5044b90e-6e4d-4b97-98c5-0c70ecbb8494)

In general, the MinIO admin console’s functionality is equivalent to that of the command-line client. However, it does have some minor differences.

First, moving objects between buckets is not possible with the client like it is with the command-line client.

Additionally, the command-line client also has a number of sub-commands that do not exist in the admin console. For example, the diff, du, and pipe sub-commands all mimic standard Unix commands and do not have an equivalent in the admin console.

#### The MinIO SDK

MinIO publishes the following Software Development Kits (SDK):

Go
Python
Java
.NET
JavaScript
Haskell
C++


#### Object Management 
An object is binary data, such as images, audio files, spreadsheets, or even binary executable code. The term “Binary Large Object” or “blob” is sometimes associated to object storage, although blobs can be anywhere from a few bytes to several terabytes in size. Object Storage platforms like MinIO provide dedicated tools and capabilities for storing, listing, and retrieving objects using a standard S3-compatible API.

Some of the object management activities are:
Object Organization and Planning
Object Versioning 
Object Retention
Object Lifecycle Management
Data Compression

#### Security and Access
You can use the MinIO Console to perform several of the identity and access management functions available in MinIO, such as:

Create child access keys that inherit the parent’s permissions.
View, manage, and create access policies.
Create and manage user credentials or groups with the built-in MinIO IDP, connect to one or more OIDC provider, or add an AD/LDAP provider for SSO.

Various sections in Minio console that are related to security are: 
Access Keys 
Policies 
Identity 
Users 
Gropus 

#### Monitoring 
MinIO provides point-in-time metrics on cluster status and operations. The MinIO Console provides a graphical display of these metrics.

For historical metrics and analytics, MinIO publishes cluster and node metrics using the Prometheus Data Model. You can use any scraping tool which supports that data model to pull metrics data from MinIO for further analysis and alerting.

#### Minio Operator 
Within the Operator’s namespace, the MinIO Operator utilizes two pods: - The Operator pod for the base Operator functions to deploy, manage, modify, and maintain tenants. - Console pod for the Operator’s Graphical User Interface, the Operator Console.

When you use the Operator to create a tenant, the tenant must have its own namespace. Within that namespace, the Operator generates the pods required by the tenant configuration.

Each pod runs three containers:

- MinIO Container that runs all of the standard MinIO functions, equivalent to basic MinIO installation on baremetal. This container stores and retrieves objects in the provided mount points (persistent volumes).
- InitContainer that only exists during the launch of the pod to manage configuration secrets during startup. Once startup completes, this container terminates.
- SideCar container that monitors configuration secrets for the tenant and updates them as they change. This container also monitors for root credentials and creates an error if it does not find root credentials.


