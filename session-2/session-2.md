# Hands-on Kubernetes-02 : Kubernetes Basics

Purpose of this hands-on training is to understand the Core concepts and the objects of K8s.

## Learning outcomes:

At the end of this session the following topics will be covered:

- K8s objects and manifest: pods, deployments, services

- Networking

- Volume management

- K8s features: Horizontal pod autoscaling (HPA), rollout and rollback of deployments.

## Outline:

- Part-1: Creating deployments

- Part-2: Scaling the cluster 

- Part-3: Rollout and rollback features

### Launch an SKS cluster with two worker nodes on CLI
```
$ exo compute sks create my-test-cluster \
    --zone ch-gva-2 \
    --service-level pro \
    --nodepool-name my-test-nodepool \
    --nodepool-size 2 \
    --nodepool-security-group sks-security-group
```

#### Apply kubeconfig settings to your kubectl cli:

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

Check existing nodes in your cluster - see namespaces
```
$ kubectl get no
```

### Volumes

#### 1-Configmap
```
$ kubectl apply -f configmap.yaml
$ kubectl apply -f configmap-env-pod.yaml
$ kubectl get pods
$ kubectl exec -it configmap-env-pod -- bash
# echo $database_url
$ kubectl delete po configmap-env-pod
$ kubectl apply -f configmap-volume-pod.yaml
$ kubectl exec -it configmap-volume-pod -- bash
# cd /home && ls -la && cat environment
```

#### 2-Secret
```
$ echo -n "user" | base64
$ echo ZXhvc2NhbGU= | base64 --decode
$ kubectl apply -f secret.yaml
$ kubectl apply -f secret-env-pod.yaml
$ kubectl get po
$ kubectl exec -it secret-env-pod -- bash
# echo $username ; echo $password
$ kubectl apply -f secret-volume-pod.yaml
$ kubectl exec -it secret-volume-pod -- bash
# cd /home ; cat username ; cat password
```

#### 3-persistent volume & persistent volume claim
```
Check `/mnt/data/` directory on the node
$ kubectl apply -f pv.yaml
$ kubectl get pv
$ kubectl apply -f pvc.yaml
$ kubectl get pvc
$ kubectl apply -f persistent-volume-pod.yaml
Check `/mnt/data/` directory on the node
$ kubectl exec -it persistent-volume-pod -- bash
# ls -la /usr/share/nginx/html/
# touch I-am-persistent /usr/share/nginx/html/
# ls -la /usr/share/nginx/html/
Check `/mnt/data/` directory on the node
~$ ls -la /mnt/data/
Delete and re-create the pod
$ kubectl delete po persistent-volume-pod
$ kubectl apply -f persistent-volume-pod.yaml
# ls -la /usr/share/nginx/html/
```

### Services

#### ClsterIp service
```
$ kubectl apply -f nginx-service-pod.yaml
$ kubectl apply -f nginx-service-clusterip.yaml
$ kubectl get svc
$ kubectl get endpoints nginx-service-clusterip
$ kexec -it nginx-service-pod -- bash
# curl 192.168.186.138:80
# curl http://localhost:80
# curl 10.104.48.227:80
# echo hello > usr/share/nginx/html/index.html 
# curl 192.168.186.138:80
# curl http://localhost:80
# curl 10.104.48.227:80
```

#### NodePort service
```
Delete all pods
$ kubectl apply -f nginx-service-pod.yaml
$ kubectl apply -f nginx-service-nodeport.yaml
$ kubectl get svc nginx-service-nodeport
$ kubectl get endpoints nginx-service-nodeport
http://89.145.166.121:30007/
```

#### LoadBalancer service
```
Delete all pods
$ kubectl apply -f nginx-service-pod.yaml
$ kubectl apply -f nginx-service-lb.yaml
$ kubectl get svc nginx-service-lb
$ kubectl get endpoints nginx-service-lb
http://89.145.166.121:30007/
$ kexec -it nginx-service-pod -- bash
# echo hello > /usr/share/nginx/html/index.html
# curl 10.104.48.227:80
# curl 192.168.186.138:80
# curl http://localhost:80
```


### Deployments

Get the documentation of Deployments and its fields.
```
kubectl explain deployments
```

Create a deployment, review and scale it
```
$ kubectl apply -f nginx-deployment.yaml
$ kubectl get deployment -o wide
$ kubectl describe deployment nginx-deployment
$ kubectl get pod -o wide
$ kubectl scale deploy nginx-deployment --replicas=5
```

See resiliency of the replicas
```
$ kubectl delete po nginx-deployment-54b9c68f67-xcf5l nginx-deployment-54b9c68f67-dpxbc nginx-deployment-54b9c68f67-kvk9f
```

Edit deployment, view previous rollout revisions then apply a rollback
```
$ kubectl edit deploy nginx-deployment
$ kubectl rollout history deploy nginx-deployment
$ kubectl rollout history deploy nginx-deployment --revision=1
$ kubectl rollout history deploy nginx-deployment --revision=2
$ kubectl rollout undo deploy nginx-deployment --to-revision=1
```

#### Horizontal pod autoscaling

```
$ kubectl scale deploy nginx-deployment --replicas=2
$ kubectl apply -f nginx-hpa.yaml
$ kubectl get hpa
$ kubectl exec -it  nginx-deployment-78788ffcff-8nhff -- bash
# apt update && apt install -y stress
# stress --cpu 2 --timeout 600
$ kubectl get hpa
$ kubectl top po
$ kubectl top no
```

Delete the deployment
```
$ kubectl delete deploy nginx-deployment
```



### Clean up
delete the nodepool
```
exo compute sks nodepool delete my-test-cluster my-test-nodepool -f
```

delete the cluster
```
exo compute sks delete my-test-cluster -f
```