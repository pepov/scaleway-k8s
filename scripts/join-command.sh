#!/bin/bash -x

if [[ -f .secret/join_command ]]; then
    VALUE=`cat .secret/join_command`
else
    VALUE=`ssh -lroot -o "StrictHostKeyChecking=no" $1 "kubeadm token create \$(kubeadm token generate) --print-join-command"`
    echo "$VALUE" > .secret/join_command
fi

jq -n --arg join "$VALUE" '{"join":$join}'