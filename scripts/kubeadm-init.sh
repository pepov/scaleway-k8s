#!/bin/bash

kubeadm init --apiserver-cert-extra-sans=`curl ifconfig.co`

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config