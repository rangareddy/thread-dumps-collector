# Thread Dumps Collector

<p align="center">
  <img src="https://github.com/rangareddy/thread-dumps-collector/blob/main/Thread_Dump_Collector_Logo.png">
</p>

**Thread Dumps Collector** is a simple shell scrpt tool, used to collect the **Thread Dumps** using either **PID** or **CONTAINER_ID** with **compressed([tar|zip])** format.

## Steps

The following are steps to use this tool:

**Step1:**
Switch as the service user that started the process.
```sh
su - <service-user-who-started-the-process>
```

**Step2:** 
Download the **thread_dumps_collector.sh** script to any location (for example /tmp) and give the **execute** permission.

```sh
cd /tmp
wget https://raw.githubusercontent.com/rangareddy/thread-dumps-collector/main/thread_dumps_collector.sh
chmod +x thread_dumps_collector.sh
```

**Step3:** 
Run the following shell script by providing the **container_id/process_id**.

```sh
sh thread_dumps_collector.sh <container_id/process_id>
```

Thanks for using this tool. Please let me know is there any feedback. 
