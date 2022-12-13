#!/bin/bash
function expect_terraformCommands() {
    if [ "$1" = "login" ]; then
        expect <<EOF
        spawn terraform login
        expect -timeout 30 "Enter a value:"
        send "yes\r"
        expect -timeout 30 "Enter a value:"
        send "$2\r"
expect eof
EOF
    elif [ "$1" = "init" ]; then
        terraform init --reconfigure | tail -10
    else
        expect <<EOF
        spawn terraform $1
        expect -timeout 30 "Enter a value:"
        send "yes\r"
        sleep 300
expect eof
EOF
    fi
}

function devopsLogger() {
    timestamp=`date +%Y-%m-%d_%H-%M-%S`
    echo -e "\033[43;30m==================================================================\033[0m"
    echo -e "\033[43;30m[$timestamp][DevOps] terraform $1 command $2\033[0m"
    echo -e "\033[43;30m==================================================================\033[0m"
}

if [ "$1" = "awscliConfigure" ]; then
    expect <<EOF
    spawn aws configure
    expect -timeout 5 -re "AWS Access Key ID*:"
    send "$2\r"
    expect -timeout 5 -re "AWS Secret Access Key*:"
    send "$3\r"
    expect -timeout 5 -re "Default region name*:"
    send "$4\r"
    expect -timeout 5 -re "Default output format*:"
    send "json\r"
expect eof
EOF
elif [ "$1" = "cloneTerraformRepository" ]; then
    gitlab_path=$2
    gitlab_id=$3
    gitlab_pw=$4

    expect <<EOF
    spawn git clone $gitlab_path /root/.dr_tf_repo
    expect -timeout 5 -re "Username for 'https://gitlab.crsdev.io*"
    send "$gitlab_id\r"
    expect -timeout 5 -re "Password for 'https://$gitlab_id@gitlab.crsdev.io*"
    send "$gitlab_pw\r"
expect eof
EOF
elif [ "$1" = "terraformLogin" ]; then
    devopsLogger login start
    commandResult=`expect_terraformCommands login $2`
    echo "$commandResult" | tail -22
elif [ "$1" = "terraformInit" ]; then
    devopsLogger init start
    expect_terraformCommands init
else
    devopsLogger $2 start
    commandResult=`expect_terraformCommands $2`
    devopsLogger $2 result
    echo "$commandResult" | tail -20
fi