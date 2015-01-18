#!/bin/bash
export EC2_HOME=`pwd`/lib/ec2-api-tools-1.7.3.0
export PATH=$PATH:$EC2_HOME/bin

# usage: runjob jobfile.sh aws_key_file instance_key
$jobfile=$1
$aws_keys_file=$2
$instance_key=$3

# Ubuntu Server 14.04 LTS (PV), SSD Volume Type - ami-98aa1cf0
ec2-run-instances \
  -n 1 \
  --aws-access-key `head -n 1 $aws_keys_file` \
  --aws-secret-key `tail -n 1 $aws_keys_file` \
  --associate-public-ip-address true \
  --instance-initiated-shutdown-behavior terminate \
  --instance-type t1.micro \
  -k $instance_key \
  --user-data-file $jobfile \
  ami-98aa1cf0
