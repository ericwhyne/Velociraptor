#!/bin/bash
ec2id=`curl http://169.254.169.254/latest/meta-data/instance-id` # yes, this is really always how you get your instance-id. I know, it's weird.
logfile="/$ec2id.log" # a log file so we can see when things failed and why
urlfile="/$ec2id-urls.txt" # this file will hold the URLs that this job is responsible for
fetchfile="/$ec2id-fetch.sh" # this is the file that evenutally holds all of the wget commands for parallel to run
warcdir="/$ec2id-warcs" # this is the directory we store all of the fetched content
warcgz="/$ec2id-warcs.tgz" # this is the compressed file that gets shipped to the result collector upon completion

date=`date`
echo "Velociraptor ran on $date" > $logfile

mkdir -p $warcdir

tail -n 1  $0 | sed 's/^#//' | base64 -d | gunzip > $urlfile # unpack the payload

cat $urlfile | while read url
do
  # RFC 3548 suggests replace / character with the underscore _ and the + character with the minus - to be linux filename safe
  base64url=`echo $url | base64 --wrap=0 | sed 's/\//_/g' | sed 's/\+/-/g'`
  # other options --no-warc-compression, we compress the end result anyway, but this might save us from destroying our instance EBS if that node fetches a lot of content.
  echo "wget -nc --tries=10 -k --append-output=$logfile --page-requisites --warc-file=$warcdir/$base64url --directory-prefix=$warcdir/ $url" >> $fetchfile
done

# default for GNU Parallel is to run one job per cpu core; sure why not. TODO: Play with parallel settings to see what's fastest.
parallel ::: < $fetchfile

tar -zcf $warcgz $warcdir

# Ship off the results to the collector
#TODO: make this all write to s3
aws s3 cp --region $s3_bucket_region $logfile $s3_bucket >> /test-s3.txt
aws s3 cp --region $s3_bucket_region $fetchfile $s3_bucket
aws s3 cp --region $s3_bucket_region $urlfile $s3_bucket
aws s3 cp --region $s3_bucket_region $warcgz $s3_bucket


halt #on halt the instance will be terminated
#data payload is the last line of this file:
