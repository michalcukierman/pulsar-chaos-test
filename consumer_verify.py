import pulsar

client = pulsar.Client('pulsar://localhost:6650')
consumer = client.subscribe('websight/dxp/chaos-test',
                            subscription_name='python-verify',
                            initial_position=pulsar.InitialPosition.Earliest)

while True:
    msg = consumer.receive()
    print("Received message: '%s'" % msg.data(5000))
    consumer.acknowledge(msg)

client.close()