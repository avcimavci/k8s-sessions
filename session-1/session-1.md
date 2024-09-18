# Hands-on Kubernetes-01 : Kubernetes Intro

Purpose of this hands-on training is to understand the k8s cluster with its components as well as Exoscale managed SKS services.

## Learning outcomes:

At the end of this session the following topics will be covered:

- SKS cluster, nodepool/instance pool, k8s nodes, pods, namespaces

- Core components of k8s (Control plane and worker node components)

- Managing cluster with basic k8s commands

## Outline:

- Part-1: Setting up the Kubernetes Cluster

- Part-2: Observing the resiliency and sclability features/aspects of k8s 

- Part-3: Managing the cluster via kubectl (Declarative and imperative methods)

### Create the cluster (Via exoscale console or exo cli tool)
```
$ exo compute sks create my-test-cluster \
    --zone ch-gva-2 \
    --kubernetes-version "1.28.13" \
    --service-level pro \
    --nodepool-name my-test-nodepool \
    --nodepool-size 2 \
    --nodepool-security-group sks-security-group
```

Launch an SKS cluster with two worker nodes using the exoscale web interface.
We can also do it on our cli using imperative method
```
Name: my-test-cluster
Level: Pro
Control Plane version: 1.29.8
CNI: CALICO
Addons: Select all options except metrics-server
```

### Apply kubeconfig settings to your kubectl cli:

Get the cluster details
```
$ exo compute sks show my-test-cluster --zone ch-gva-2
```

Generate and export kubeconfig file to let kubectl start managing your cluster
```
$ exo compute sks kubeconfig my-test-cluster kube-admin --zone ch-gva-2 --group system:masters > my-test-cluster.kubeconfig
```

Define kubeconfig path for the KUBECONFIG variable
```
$ export KUBECONFIG=./my-test-cluster.kubeconfig
$ kubectl config view
```

Check existing nodes and pods in your cluster - see namespaces
```
$ kubectl get nodes / kubectl get no
$ kubectl get pods / kubectl get po
$ kubectl get po --all-namespaces
$ kubectl get namespaces / kubectl get ns
```

The names and short names of some API resources

|NAME|SHORTNAMES|
|----|----------|
|deployments|deploy
|nodes      |no
|pods       |po
|services   |svc
|namespaces |ns

Check cluster info and kubectl help -- see headers of api-resources
```
$ kubectl cluster-info
$ kubectl version
$ kubectl help
$ kubectl api-resources
$ kubectl explain pvc
$ kubectl get namespaces
$ kubectl get po -A
```

Upgrade the cluster control plane
```
$ exo compute sks upgrade my-test-cluster --zone ch-gva-2 1.29.8
```

Create a nodepool with 2 nodes size on exoscale console
```
$ exo compute sks nodepool list
$ exo c instance list
$ kubectl get no -o wide
```
Delete an instance from the console and observe the scaling feature in action as it works to maintain cluster resilience
```
$ exo c instance list
$ kubectl get no -o wide
$ kubectl get po -A (see kube-system pods increasing with the nodes)
```

Check one of the kube-proxy pods running in the kube-system namespace and exit
```
$ kubectl exec -it -n kube-system <kube-proxy-ID> -- /bin/sh
# iptables -L
```

Check kubectl for pod description
```
$ kubectl explain po
```

Create a pod running Nginx image
```
$ kubectl apply -f nginx-pod.yaml
$ kubectl run nginx --image=nginx
$ kubectl get po
$ kubectl get po -o wide
```

Apply the nginx-pod2.yaml pod manifest with the same configuration -- see unchanged (etcd relationship)
```
$ kubectl apply -f nginx-pod-2.yaml 
pod/nginx-pod unchanged
```

Change pod name as nginx-pod-2, re-apply the manifest and see pods distributed among nodes (it may or may not)
```
$ kubectl apply -f nginx-pod-2.yaml
pod/nginx-pod-2 created

$ kubectl get po -o wide 
```

Connect to a pod, see its OS and ping the other pod
```
$ kubectl exec -it nginx-pod -- env
$ kubectl exec -it nginx-pod -- bash
root@nginx-pod:/# cat /etc/os-release
root@nginx-pod:/# apt update && apt install -y iputils-ping
root@nginx-pod:/# ping -c 2 <nginx-pod-2 IP>
```

Try to see the node status
```
$ kubectl top no
error: Metrics API not available
```

Enable metrics-server on exoscale console then see the changes
```
$ kubectl get po -n kube-system
$ kubectl top no
$ kubectl top po
```

Port forwarding
```
$ kubectl exec -it nginx -- bash
root@nginx:/# apt update && apt install -y vim
root@nginx:/# vi /usr/share/nginx/html/index.html
$ kubectl port-forward pod/nginx-pod 8080:80
$ kubectl port-forward pod/nginx-pod-2 8081:80
```

Connect to a node and check the Container Runtime (containerd.service)
```
$ ssh ubuntu@<Node Public IP>
ubuntu@pool-3867a-akgvq:~$ sudo systemctl status containerd.service
ubuntu@pool-3867a-akgvq:~$ sudo ctr -n k8s.io containers list
ubuntu@pool-3867a-akgvq:~$ sudo ctr -n k8s.io containers info <Container ID>
```

Delete some pods using imperative and declarative methods
```
$ kubectl delete pod nginx-pod
$ kubectl delete -f nginx-pod-2.yaml 
```

### Fun! 🎉💃🥳
Create your first fun pod to play a super-mario game by following these instructions:
- Container name: `super-mario`
- Container image: `pengbai/docker-supermario`
- Container port: `8080`

Access your 'super-mario' container over port `8600` from your browser.
<<<Don't get too caught up in it 😃>>>



### Clean up
Delete the nodepool
```
$ exo compute sks nodepool delete my-test-cluster my-test-nodepool -f
```

Delete the cluster
```
$ exo compute sks delete my-test-cluster -f
```