#!/bin/bash

list_of_urls=$1
num_instances=$2
s3_bucket=$3
s3_bucket_region=$4
tempdir=$5

mkdir -p $tempdir/split
#TODO: cat $list_of_urls | sort | uniq | shuf |
#split -n $num_instances $list_of_urls $tempdir/split/sublist-
split -l $((`wc -l < $list_of_urls`/$num_instances)) $list_of_urls $tempdir/split/sublist-
mkdir -p $tempdir/jobs

for file in $tempdir/split/sublist-*
do
  #echo "creating job for file $file"
  jobfilename="$tempdir/jobs/job-`basename $file`.sh"
  cat job-header.sh > $jobfilename
  echo "s3_bucket=$s3_bucket" >> $jobfilename
  echo "s3_bucket_region=$s3_bucket_region" >> $jobfilename
  cat job-footer.sh >> $jobfilename
  # payload of urls is sent as the last line of the file.
  echo \#`cat $file | gzip | base64 --wrap=0` >> $jobfilename
done

# This directory is used by runjob.sh to capture status.
mkdir -p $tempdir/status
