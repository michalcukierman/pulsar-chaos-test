#!/bin/bash
# set -x

trap printout SIGINT
printout() {
    echo ""
    [[ ! -z "$PRODUCER_PID" ]] && echo "Exiting... Killing Producer" && kill -9 $PRODUCER_PID
    [[ ! -z "$CONSUMER_PID" ]] && echo "Exiting... Killing Consumer" && kill -9 $CONSUMER_PID
    echo "Finished run.sh script"
    exit
}

echo "Creating output dirctory ./out"
rm -rf ./out
mkdir ./out

kubectl exec --namespace pulsar -t pulsar-toolset-0 -- bin/pulsar-admin topics partitioned-stats websight/dxp/chaos-topic > out/initial-stats.out
kubectl exec --namespace pulsar -t pulsar-toolset-0 -- bin/pulsar-admin topics partitioned-stats-internal websight/dxp/chaos-topic > out/initial-stats-internal.out


echo "Starting consumer"
python3 consumer.py &> out/consumer.log &
CONSUMER_PID=$!
echo "Starting producer"
python3 producer.py &> out/producer.log &
PRODUCER_PID=$! 
echo "Waiting (30s) for the messages to be produced to chaos-topic"
sleep 30
kubectl exec --namespace pulsar -t pulsar-toolset-0 -- bin/pulsar-admin topics partitioned-stats websight/dxp/chaos-topic > out/pre-stats.out
kubectl exec --namespace pulsar -t pulsar-toolset-0 -- bin/pulsar-admin topics partitioned-stats-internal websight/dxp/chaos-topic > out/pre-stats-internal.out

echo "Restarting broker pods"
kubectl delete pod pulsar-broker-0 -n pulsar
kubectl delete pod pulsar-broker-1 -n pulsar
kubectl delete pod pulsar-broker-2 -n pulsar

echo "Waiting (30s) for the brokers to start"
sleep 30

echo "Killing producer and consumer"
kill -9 $PRODUCER_PID
kill -9 $CONSUMER_PID

kubectl exec --namespace pulsar -t pulsar-toolset-0 -- bin/pulsar-admin topics partitioned-stats websight/dxp/chaos-topic > out/post-stats.out
kubectl exec --namespace pulsar -t pulsar-toolset-0 -- bin/pulsar-admin topics partitioned-stats-internal websight/dxp/chaos-topic > out/post-stats-internal.out
sh run_verify.sh