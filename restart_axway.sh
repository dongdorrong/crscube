#!/bin/bash
echo "[DEVOPS] script user : `whoami`"
echo "[DEVOPS] 'java' process details\n> `ps -ef | grep java | grep -v grep`"

while true; do
        ps -ef | grep 'java' | awk '{print $2}' | xargs kill

        sleep 5s

        SERVICE_COUNT=`ps -ef | grep java | grep -v grep | wc -l`
        echo "[DEVOPS] killall java, service_count > $SERVICE_COUNT"

        if [ $SERVICE_COUNT -eq 0 ]; then
                echo "[DEVOPS] while loop break"
                break
        else
                echo "[DEVOPS] java process not 0, service_count > $SERVICE_COUNT"
        fi
done

echo "[DEVOPS] AxWay Service restart"
sh -x /home/crsdev/Axway/Activator/bin/startServer

echo "[DEVOPS] 'java' process details\n> `ps -ef | grep java | grep -v grep`"
echo "[DEVOPS] 'java' netstat details\n> `netstat -nlp | grep java | grep -v grep`"