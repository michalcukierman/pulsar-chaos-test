import pulsar

while True:
    try:
        client = pulsar.Client('pulsar://localhost:6650')
        producer = client.create_producer('websight/dxp/monolog')

        producer.send(('verification-message').encode('utf-8'))
        for i in range(10*1000*1000):
            producer.send(('hello-pulsar-%d' % i).encode('utf-8'))

        client.close()
    except Exception:
        print("Error in producer")