#!/bin/bash
# set -x

trap printout SIGINT
printout() {
    echo ""
    echo "Finished run_proxy.sh script"
    exit
}

function forward_proxy() {
    while [ 1 ]; do 
        kubectl port-forward service/pulsar-proxy  6650:6650 -n pulsar
        echo "Reconnecting... Creating new port-forward process" 
    done
}

echo "Starting proxy"
forward_proxy