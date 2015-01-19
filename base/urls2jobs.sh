#!/bin/bash

list_of_urls=$1
num_instances=$2
s3_bucket=$3
s3_bucket_region=$4

mkdir -p temp
rm -f temp/*
split -n $num_instances $list_of_urls temp/sublist-

jobsdir="jobs"
mkdir -p $jobsdir
rm -f $jobsdir/*

for file in temp/sublist-*
do
  #echo "creating job for file $file"
  jobfilename="$jobsdir/job-`basename $file`.sh"
  cat job-header.sh > $jobfilename
  echo "s3_bucket=$s3_bucket" >> $jobfilename
  echo "s3_bucket_region=$s3_bucket_region" >> $jobfilename
  cat job-footer.sh >> $jobfilename
  # payload of urls is sent as the last line of the file.
  echo \#`cat $file | gzip | base64 --wrap=0` >> $jobfilename
done
