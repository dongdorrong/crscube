#!/bin/bash

server_name=$1
bucket_name=$2

# Check Server IP Address
ip_address=`hostname -I`

# Download Script
aws s3 cp s3://$bucket_name/script/linux_v4.3.bin /tmp/
aws s3 cp s3://$bucket_name/command/run.sh /tmp/

# Check Script
script=`ls /tmp/linux_v4.3.bin`
if [[ "$script" == *"No such file or directory"* ]];then
        # Download Fail
        check_1="False"
else
        # Download Success
        check_1="True"
fi

if [[ "$check_1" == *"True"* ]];then
        # Change Script's Authentication
        sudo chmod 777 /tmp/linux_v4.3.bin
        # Execute Script
        (echo $ip_address;) | sudo /tmp/linux_v4.3.bin
fi

# Check Result File
result_file=`find /tmp -name '*.xml'`
if [[ "$result_file" == *".xml"* ]];then
  # Security Examine Success
        check_2="True"
else
  # Security Examine Fail
        check_2="False"
fi

# Upload Result File
if [[ "$check_2" == *"True"* ]];then
        aws s3 cp /tmp/${result_file#/tmp/} s3://$bucket_name/result/$server_name/${result_file#/tmp/}
fi

# Check Upload
upload=`aws s3 ls s3://$bucket_name/result/$server_name/${result_file#/tmp/}`
if [ -z "$upload" ];then
        check_3="False"
else
        check_3="True"
fi

# Print check_* variables
echo "check_1 > $check_1 (True : Download Success / False : Download Fail)"
echo "check_2 > $check_2 (True : Examine Success / False : Examine Fail)"
echo "check_3 > $check_3 (True : Upload Success / False : Upload Fail)"