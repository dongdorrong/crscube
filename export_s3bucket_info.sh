#!/bin/bash
BUCKET_NAME=$1

OPTION_BUCKET_NAME="--bucket $BUCKET_NAME"

LOCATION="{\"Location\":`aws s3api get-bucket-location $OPTION_BUCKET_NAME`}"
echo $LOCATION > $HOME/devops_script_location.json

POLICY="{\"Policy\":`aws s3api get-bucket-policy --query Policy --output text $OPTION_BUCKET_NAME`}"
echo $POLICY > $HOME/devops_script_policy.json

#POLICY_STATUS="{\"POLICY_STATUS\":`aws s3api get-bucket-policy-status $OPTION_BUCKET_NAME`}"
POLICY_STATUS=`aws s3api get-bucket-policy-status $OPTION_BUCKET_NAME`
echo $POLICY_STATUS > $HOME/devops_script_policy_status.json

#TAGGING="{\"TAGGING\":`aws s3api get-bucket-tagging $OPTION_BUCKET_NAME`}"
TAGGING=`aws s3api get-bucket-tagging $OPTION_BUCKET_NAME`
echo $TAGGING > $HOME/devops_script_tagging.json

WEBSITE="{\"Website\":`aws s3api get-bucket-website $OPTION_BUCKET_NAME`}"
echo $WEBSITE > $HOME/devops_script_website.json

jq -rs 'reduce .[] as $item ({}; . * $item)' \
$HOME/devops_script_location.json \
$HOME/devops_script_policy.json \
$HOME/devops_script_policy_status.json \
$HOME/devops_script_tagging.json \
$HOME/devops_script_website.json > $HOME/$BUCKET_NAME.json

rm -rf $HOME/devops_script_*.json

cat $HOME/$BUCKET_NAME.json
