#!/bin/bash
#####################################
# Declare variables
#####################################
ACCESS_KEY="VAR_AKEY"
SECRET_KEY="VAR_SKEY"
SOLUTION_NAME="VAR_SNAME"
SOLUTION_ENVIRONMENT="VAR_SENV"
SOLUTION_REGION="VAR_SR"
CONTAINER_NAME="VAR_CN"
BUCKET_NAME="VAR_BN"
LAMBDA_TRIGGER="VAR_LT"

TIMESTAMP=`date +%Y%m%d-%H%M`
PROC_JAVA_PID=`ps -ef | grep java | grep -v grep | awk '{ print $2}'`
FILENAME=`echo $HOSTNAME | cut -d '.' -f1`
echo "############################################################################"
echo "[DevOps - Debug] ACCESS_KEY >>> $ACCESS_KEY"
echo "[DevOps - Debug] SECRET_KEY >>> $SECRET_KEY"
echo "[DevOps - Debug] SOLUTION_NAME >>> $SOLUTION_NAME"
echo "[DevOps - Debug] SOLUTION_ENVIRONMENT >>> $SOLUTION_ENVIRONMENT"
echo "[DevOps - Debug] SOLUTION_REGION >>> $SOLUTION_REGION"
echo "[DevOps - Debug] BUCKET_NAME >>> $BUCKET_NAME"
echo "[DevOps - Debug] LAMBDA_TRIGGER >>> $LAMBDA_TRIGGER"
echo -e "\n[DevOps - Debug] TIMESTAMP >>> $TIMESTAMP"
echo "[DevOps - Debug] PROC_JAVA_PID >>> $PROC_JAVA_PID"
echo "[DevOps - Debug] FILENAME >>> $FILENAME"
echo "############################################################################"

#####################################
# Remove /root/temp.txt
#####################################
rm -rf /root/temp_"$LAMBDA_TRIGGER".txt

#####################################
# Install package
#####################################
echo "[DevOps - Debug] yum -y install procps tar gzip vim aws-cli"
echo "############################################################################"
yum -y install procps tar gzip vim aws-cli > /dev/null 2>&1

#####################################
# Set aws config, credential
#####################################
mkdir /root/.aws
touch /root/.aws/config && touch /root/.aws/credentials

echo "[default]" > /root/.aws/config
echo "region=${AWS_REGION}" >> /root/.aws/config

echo "[default]" > /root/.aws/credentials
echo "aws_access_key_id=${ACCESS_KEY}" >> /root/.aws/credentials
echo "aws_secret_access_key=${SECRET_KEY}" >> /root/.aws/credentials

echo -e "[DevOps - Debug] /root/.aws/config >>> \n`cat /root/.aws/config`"
echo -e "[DevOps - Debug] /root/.aws/credentials >>> \n`cat /root/.aws/credentials`"
echo "############################################################################"

#####################################
# Create dump files (Heap, Thread)
# - Thread : CPU Utilization
# - Heap   : Memory Utilization
#####################################
cd /root && mkdir /root/"$HOSTNAME"_"$LAMBDA_TRIGGER"

if [ "$LAMBDA_TRIGGER" = "CPUUtilization" ]
then
    echo "[DevOps - Debug] thread dump start!"

    for cnt in {1,2,3,4,5}
    do
        /bin/jstack $PROC_JAVA_PID > /root/"$HOSTNAME"_"$LAMBDA_TRIGGER"/thread_dump_$cnt.txt
        sleep 3s
    done
    echo "[DevOps - Debug] thread dump done."
else
    echo "[DevOps - Debug] heap dump start!"
    /bin/jmap -dump:file=/root/"$HOSTNAME"_"$LAMBDA_TRIGGER"/heap_dump.hprof $PROC_JAVA_PID
    echo "[DevOps - Debug] heap dump done."
fi

tar -zcvf /root/"$FILENAME"_"$TIMESTAMP"_"$LAMBDA_TRIGGER".tar.gz "$HOSTNAME"_"$LAMBDA_TRIGGER"

echo -e "[DevOps - Debug] ls -alh /root/$HOSNTMAE >>> \n`ls -alh /root/$HOSTNAME`"
echo -e "[DevOps - Debug] ls -alh /root/*.tar.gz >>> \n`ls -alh /root/*.tar.gz`"
echo "############################################################################"

#####################################
# Transfer application dump file
#####################################
echo "[DevOps - Debug] Transfer dump file"
echo "############################################################################"
aws s3 cp /root/"$FILENAME"_"$TIMESTAMP"_"$LAMBDA_TRIGGER".tar.gz s3://$BUCKET_NAME/$SOLUTION_NAME/$SOLUTION_ENVIRONMENT/$CONTAINER_NAME/"$FILENAME"_"$TIMESTAMP"_"$LAMBDA_TRIGGER".tar.gz
