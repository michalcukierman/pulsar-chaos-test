# Pulsar chaos testing

## Requirement
1. Installed pip3, python3
2. Depencencies installed:
```
pip3 install pulsar-client==3.2.0
```

## Running
1. Create cluster-1 on GCP 

- Use default settings and three `e2-standard-4` nodes
- Use us-central1-c zone


2. Configure kubectl context.

Example command line:
```
gcloud container clusters get-credentials cluster-1 --region us-central1-c --project <your project id>
```

3. Install pulsar

```
cd environment-gcp
sh deploy.sh
cd ..
```

3. Create partitioned topic `chaos-topic`

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
sh run.sh
 ```

## Troubleshooting
- Sometimes background processes are not killed, it can be done by running.
Make sure to use it with causion, as it may affect other processes runing on your machine.
Tested on MacOS
```
killall -9 Python
killall -9 bash
killall -9 kubectl
```

- Sometimes the verification need to be re-run (output in a console).