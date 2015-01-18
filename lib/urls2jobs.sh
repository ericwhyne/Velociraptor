#!/bin/bash
# Usage: urls2jobs listofurls.txt <number_of_instances> collector_key.pem <collector_ip>

#TODO: add argv checking and explanation here

$list_of_urls=$1
$num_instances=$2
$collector_key_file=$3
$collector_ip=$4

mkdir -p temp
rm temp/*
split -n $num_instances $list_of_urls temp/sublist-

jobsdir="jobs"
mkdir -p $jobsdir
rm $jobsdir/*

for file in temp/sublist-*
do
  echo "creating job for file $file";
  jobfilename="$jobsdir/job-`basename $file`.sh"
  cat job-header.sh > $jobfilename
  echo "collector_key='`cat $collector_key_file | base64 --wrap=0`'" >> $jobfilename
  echo "collector_ip=$collector_ip" >> $jobfilename

  cat job-footer.sh >> $jobfilename
  # payload of urls is sent as the last line of the file.
  echo \#`cat $file | base64 --wrap=0` >> $jobfilename
done
