#!/bin/bash
# set -x

tenant=${1:-websight}
namespace=${2:-dxp}

TOOLSET_POD=`kubectl get pods --namespace pulsar --selector component=toolset --no-headers -o custom-columns=":metadata.name"`

function execInToolset {
  local command=$1
  kubectl exec --namespace pulsar -t $TOOLSET_POD -- $command
}

function createTenant {
  local tenantName=$1
  execInToolset "bin/pulsar-admin tenants get ${tenant}" > /dev/null 2>&1
  local exists=$?
  if [ $exists -ne 0 ]; then
    echo "Creating tenant: '${tenantName}'"
    execInToolset "bin/pulsar-admin tenants create ${tenant}"
  else
    echo "Tenant '${tenantName}' already exists"
  fi
}

function createNamespace {
  local tenantName=$1
  local namespaceName=$2
  execInToolset "bin/pulsar-admin namespaces list ${tenantName}" | grep $namespaceName
  local exists=$?
  if [ $exists -ne 0 ]; then
    echo "Creating namespace '${tenantName}/${namespaceName}'"
    execInToolset "bin/pulsar-admin namespaces create ${tenantName}/${namespaceName}"
  else
    echo "Namespace '${tenantName}/${namespaceName}' already exists"
  fi
}

function createTopic {
  local tenantName=$1
  local namespaceName=$2
  local topicName=$3
  execInToolset "bin/pulsar-admin topics list ${tenantName}/${namespaceName}" | grep $topicName
  local exists=$?
  if [ $exists -ne 0 ]; then
    echo "Creating topic 'persistent://${tenantName}/${namespaceName}/${topicName}'"
    execInToolset "bin/pulsar-admin topics create persistent://${tenantName}/${namespaceName}/${topicName}"
  else
    echo "Topic 'persistent://${tenantName}/${namespaceName}/${topicName}' already exists"
  fi
}

function createPartitionedTopic {
  local tenantName=$1
  local namespaceName=$2
  local topicName=$3
  local partitions=$4
  execInToolset "bin/pulsar-admin topics list-partitioned-topics ${tenantName}/${namespaceName}" | grep $topicName
  local exists=$?
  if [ $exists -ne 0 ]; then
    echo "Creating partitioned topic 'persistent://${tenantName}/${namespaceName}/${topicName}'"
    execInToolset "bin/pulsar-admin topics create-partitioned-topic persistent://${tenantName}/${namespaceName}/${topicName} --partitions ${partitions}"
  else
    echo "Partitioned topic 'persistent://${tenantName}/${namespaceName}/${topicName}' already exists"
  fi
}

function deletePartitionedTopic {
  local tenantName=$1
  local namespaceName=$2
  local topicName=$3
  local partitions=$4
  execInToolset "bin/pulsar-admin topics list-partitioned-topics ${tenantName}/${namespaceName}" | grep "${topicName}"
  local exists=$?
  if [ $exists -eq 0 ]; then
    echo "Topic 'chaos-test' already exists. Deleting forcefully"
    execInToolset "bin/pulsar-admin topics delete-partitioned-topic persistent://${tenant}/${namespace}/${topicName} --force"
  fi
}

# Create tenant and namespace if does not exist
createTenant $tenant
createNamespace $tenant $namespace

# Delete old chaos-test topic
deletePartitionedTopic $tenant $namespace chaos-test 
# Create chaos-test topic
createPartitionedTopic $tenant $namespace chaos-test 12
execInToolset "bin/pulsar-admin topics set-retention persistent://${tenant}/${namespace}/chaos-test --size -1 --time -1"