# Pulsar chaos testing

## Running
1. Make sure that kubectl is configured with valid K8S cluster with Pulsar installed
2. Create partitioned topic `monolog`

 ```
sh run_prepare_topic.sh
 ```

3. [Optionally] Run Proxy

 The script will run a proxy forward in a loop (with reconnecting)
 ```
sh run_proxy.sh
 ```

4. Run the test

 Execute the command:
 ```
sh run_proxy.sh
 ```

## Troubleshooting
Sometimes background processes are not killed, it can be done by running.
Make sure to use it with causion, as it may affect other processes runing on your machine.
Tested on MacOS
```
killall -9 Python
killall -9 bash
killall -9 kubectl
```