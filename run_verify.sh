echo "Waiting for verification message with receive timeout 5000ms"
echo "If the process hangs, type CTRL+C (give it some minutes)"
python3 consumer_verify.py &> out/verification.log

echo ""

if grep -q "_pulsar.ConnectError: Pulsar error: ConnectError" "./out/verification.log"; then
    echo "Connection error, execute run_verify.sh again"
    exit 1
fi

echo "Results:"
if grep -q "Partitions need to create" "./out/verification.log"; then
    echo "NOK Missing partitions found"
fi

if grep -q verification-message "./out/consumer.log"; then
  echo "OK 'verification-message' was present in 'chaos-topic' topic before restart"
else 
  echo "NOK 'verification-message' was not present in 'chaos-topic' topic before restart"
fi

if grep -q verification-message "./out/verification.log"; then
  echo "OK 'verification-message' is present in 'chaos-topic' topic after restart"
else 
  echo "NOK 'verification-message' is not present in 'chaos-topic' topic after restart"
fi

echo "Messages available before restart:"
cat out/consumer.log | grep "Received message" | grep "hello-pulsar" | sort | uniq | wc -l
echo "Messages available after restart:"
cat out/verification.log | grep "Received message" | grep "hello-pulsar" | sort | uniq | wc -l