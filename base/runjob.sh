#!/bin/bash
echo Starting job
export EC2_HOME=`pwd`/lib/ec2-api-tools-1.7.3.0
export PATH=$PATH:$EC2_HOME/bin
# usage: runjob jobfile.sh aws_key_file instance_key
jobfile=$1
worker_key_pair_name=$2
ec2_image=$3
instance_role=$4
availability_zone=$5

aws ec2 run-instances \
  --image-id $ec2_image \
  --key-name $worker_key_pair_name \
  --user-data file://$jobfile \
  --instance-type t1.micro \
  --associate-public-ip-address \
  --iam-instance-profile Name=$instance_role \
  --instance-initiated-shutdown-behavior terminate \
  --count 1 \
