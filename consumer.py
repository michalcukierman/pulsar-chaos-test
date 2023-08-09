import pulsar

client = pulsar.Client('pulsar://localhost:6650')
consumer = client.subscribe('websight/dxp/chaos-topic',
                            subscription_name='python-consume',
                            initial_position=pulsar.InitialPosition.Earliest)

while True:
    msg = consumer.receive()
    print("Received message: '%s'" % msg.data())
    consumer.acknowledge(msg)

client.close()