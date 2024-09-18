#!/bin/bash

exo compute security-group create sks-security-group

exo compute security-group rule add sks-security-group \
    --description "NodePort services" \
    --protocol tcp \
    --network 0.0.0.0/0 \
    --port 30000-32767

exo compute security-group rule add sks-security-group \
    --description "SKS kubelet" \
    --protocol tcp \
    --port 10250 \
    --security-group sks-security-group
# For Calico as CNI plugin (default):
exo compute security-group rule add sks-security-group \
    --description "Calico traffic" \
    --protocol udp \
    --port 4789 \
    --security-group sks-security-group

# For Cilium as CNI plugin:
exo compute security-group rule add sks-security-group \
    --description "Cilium (healthcheck)" \
    --protocol icmp \
    --icmp-type 8 \
    --icmp-code 0 \
    --security-group sks-security-group

exo compute security-group rule add sks-security-group \
    --description "Cilium (vxlan)" \
    --protocol udp \
    --port 8472 \
    --security-group sks-security-group

exo compute security-group rule add sks-security-group \
    --description "Cilium (healthcheck)" \
    --protocol tcp \
    --port 4240 \
    --security-group sks-security-group

exo compute security-group rule add sks-security-group \
    --description "ssh" \
    --protocol tcp \
    --port 22 \
    --security-group sks-security-group

exo compute security-group rule add sks-security-group \
    --description "http" \
    --protocol tcp \
    --port 80 \
    --security-group sks-security-group

alias k='kubectl'
alias kgp='kubectl get pods -o wide'
alias kgn='kubectl get nodes -o wide'
alias kap='kubectl apply -f'
alias kd='kubectl delete -f'
alias kexec='kubectl exec -it'
