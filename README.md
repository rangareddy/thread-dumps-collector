# Thread Dumps Collector

<p align="center">
  <img src="https://github.com/rangareddy/thread-dumps-collector/blob/main/Thread_Dump_Collector_Logo.png">
</p>

By using this tool, we can collect the **Thread Dumps** with **compressed([tar|zip])** format.

The following are steps to use this tool:

**Step1:** Download the **thread_dumps_collector.sh** script to any temp location (for example /tmp) and give the **execute** permission.
```sh
cd /tmp
wget https://raw.githubusercontent.com/rangareddy/thread-dumps-collector/main/thread_dumps_collector.sh
chmod +x thread_dumps_collector.sh
```
**Step2:** While Runing the **spark_logs_extractor.sh** script, provide the application_id.
```sh
sh thread_dumps_collector.sh <container_id>
```
> Replace **container_id** with your **Yarn Container Id**.


