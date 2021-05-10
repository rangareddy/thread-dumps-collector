#!/bin/bash

#####################################################################################################################
#  _______ _                        _   _____                               _____      _ _           _              #
# |__   __| |                      | | |  __ \                             / ____|    | | |         | |             #
#    | |  | |__  _ __ ___  __ _  __| | | |  | |_   _ _ __ ___  _ __  ___  | |     ___ | | | ___  ___| |_ ___  _ __  #
#    | |  | '_ \| '__/ _ \/ _` |/ _` | | |  | | | | | '_ ` _ \| '_ \/ __| | |    / _ \| | |/ _ \/ __| __/ _ \| '__| #
#    | |  | | | | | |  __/ (_| | (_| | | |__| | |_| | | | | | | |_) \__ \ | |___| (_) | | |  __/ (__| || (_) | |    #
#    |_|  |_| |_|_|  \___|\__,_|\__,_| |_____/ \__,_|_| |_| |_| .__/|___/  \_____\___/|_|_|\___|\___|\__\___/|_|    #
#                                                             | |                                                   #
#                                                             |_|                                                   #
#                                                                                                                   #
#  Usage   : thread_dumps_collector.sh <container_id>                                                               #
#  Author  : Ranga Reddy                                                                                            #
#  Version : v1.0                                                                                                   #
#  Date    : 05-May-2021                                                                                            #
#####################################################################################################################

SCRIPT=`basename "$0"`

echo ""
echo "Running the <$SCRIPT> script"
echo ""

if [ $# -lt 1 ]; then
    echo "Usage   : $SCRIPT <YARN_Container_ID>"
    echo "Example : $SCRIPT container_e08_1618853899304_0014_01_000002"
    exit 1
fi

CONTAINER_ID=$1

container_result=`ps -ef |grep $CONTAINER_ID |grep -v -e bash -e container-executor -e grep`
application_result=`grep application_ <<< "$container_result"`

if [ -z "$application_result" ]; then
    echo "Application details is not found for container <$CONTAINER_ID> in host <`hostname`>."
    exit 1;
fi

PROCESS_OWNER_USER=`echo $container_result | awk '{print $1}'`
PID=`echo $container_result | awk '{print $2}'`

echo "OWNER_USER    :   $PROCESS_OWNER_USER"
echo "PID           :   $PID"

JAVA_HOME_TMP="`realpath /usr/java/jdk*`"
JAVA_HOME=${JAVA_HOME:-"${JAVA_HOME_TMP}"}

SLEEP_INTERVAL=${SLEEP_INTERVAL:-5}         # defaults to 5 seconds
NUM_OF_THREAD_DUMPS=${NUM_THREAD_DUMPS:-10}    # defaults to 10 times

THREAD_DUMP_DIR=/tmp/${PID}

# create thread dump output directory
mkdir -p ${THREAD_DUMP_DIR}

IS_JAVA_HOME_EXISTS=false
if [ -d "${JAVA_HOME}" ]; then
    IS_JAVA_HOME_EXISTS=true
    echo "JAVA_HOME $JAVA_HOME"
fi

if [ ps -p $PID > /dev/null]; then
    THREAD_COUNT=0
    while [ $THREAD_COUNT -lt $NUM_OF_THREAD_DUMPS ]
    do
        CURRENT_TIME=$(date "+%Y_%m_%d_%H_%M_%S_%N")
        OUTPUT_PATH=${THREAD_DUMP_DIR}/Container_Jstacks_${PID}_${CURRENT_TIME}.txt;
        
        if [ ! IS_JAVA_HOME_EXISTS ]; then
            # Generate thread dump via kill -3
            kill -3 ${PID} >> ${OUTPUT_PATH}
        else
             # Generate thread dump via jstack
             sudo -u ${PROCESS_OWNER_USER} ${JAVA_HOME}/bin/jstack ${PID} >> ${OUTPUT_PATH}
        fi
        
        # increment the value
        THREAD_COUNT=`expr $THREAD_COUNT + 1`
        
        echo "Thread dump $THREAD_COUNT collected at ${CURRENT_TIME}"
        sleep $SLEEP_INTERVAL; 
    done

    # Compressing the extracted Spark logs using tar/zip compression
    EXTRACTED_FILE=""

    if [ ! -z "$(ls -A ${THREAD_DUMP_DIR})" ]; then
        if [ -x "$(command -v tar)" ]; then
            cd $THREAD_DUMP_DIR
            EXTRACTED_FILE=${PID}.tgz
            tar cvfz ${EXTRACTED_FILE} * > /dev/null 2>&1
        elif [ -x "$(command -v zip)" ]; then
            cd $THREAD_DUMP_DIR
            EXTRACTED_FILE=${PID}.zip
            zip -q -r ${EXTRACTED_FILE} *
        else
            echo "Compression formats [tar|zip] are not installed."
        fi
    fi
else 
    echo ""
    echo "PID ${PID} does not exist."
    echo ""
fi

echo "Thread Dumps collected successfully to <${EXTRACTED_FILE}> location."

echo ""
echo "Script <$SCRIPT> executed successfully"
echo ""
