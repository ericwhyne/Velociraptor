#!/bin/bash
# usage: runjob jobfile.sh aws_key_file instance_key
jobfile=$1
worker_key_pair_name=$2
ec2_image=$3
instance_role=$4
availability_zone=$5
tempdir=$6

aws ec2 run-instances \
  --image-id $ec2_image \
  --key-name $worker_key_pair_name \
  --user-data file://$jobfile \
  --instance-type t1.micro \
  --associate-public-ip-address \
  --iam-instance-profile Name=$instance_role \
  --instance-initiated-shutdown-behavior terminate \
  --count 1 \
> $tempdir/status/`basename $jobfile`-init.json
