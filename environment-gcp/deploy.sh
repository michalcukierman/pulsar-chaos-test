helm repo add apache https://pulsar.apache.org/charts
helm repo update
helm install pulsar -n pulsar -f ./values.yaml apache/pulsar --create-namespace
#helm upgrade pulsar -n pulsar -f ./values.yaml apache/pulsar