#!/bin/bash

scp -o "StrictHostKeyChecking=no" root@$1:.kube/config $2/.secret/kubeconfig
export KUBECONFIG=$2/.secret/kubeconfig
kubectl config set 'clusters.kubernetes.server' https://$1:6443 --insecure-skip-tls-verify=true