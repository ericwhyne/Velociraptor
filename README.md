# Velociraptor
![Velociraptor](http://upload.wikimedia.org/wikipedia/commons/c/cd/Velociraptor_dinoguy2.jpg)

Velociraptor takes a list of urls and launches parallel AWS EC2 instances which then run wget in parallel to fetch the html and images into Web Archive .warc files and store them in an S3 Bucket.
Parallelism is managed by GNU Parallel and AWS is managed by AWS CLI. This project is not associated with AWS and may use other cloud service providers in the future.

Further reading:
* [Warc](http://en.wikipedia.org/wiki/Web_ARChive)
* [Warc Tools from the Internet Archive](https://github.com/internetarchive/warc)
* [GNU Parallel](http://www.gnu.org/software/parallel/)
* [AWS Command Line Interface](http://aws.amazon.com/cli/)

# Velociraptor Quickstart:

You'll need an [Amazon AWS account](http://aws.amazon.com/) to us this software for the moment.

Velociraptor uses one configuration file. Modify example.cfg as you complete the following steps and save it with a descriptive name for your job.

Go to the AWS EC2 interface and create a keypair. Save the keyname.pem to your ~/.ssh/ directory and chmod 600.
Then, fix the following two options in the configuration file:
* worker_key_pair_name="velociraptor"
* worker_private_key_file="~/.ssh/velociraptor.pem"

Go to the AWS S3 interface and create a bucket. This is where your results will be sent to. Fix the following two options in the config file with the details of your bucket.
* s3_bucket="s3://velociraptor-collect"
* s3_bucket_region="us-east-1"

Use the AWS IAM interface to describe the permissions the nodes will run at. The role you create for your worker
nodes needs to be able to write to the bucket you created above, nothing else. The default "data-pipeline" role works.
Please be aware that there might be a bug in AWS's role creation software. Sometimes it fails at providing the Instance Profile ARN.
Here is a picture explaining what to look for, if it fails just try again.
Fix the following option in the config file with whatever you named  your role:
* instance_role="velociraptor"

Next you define a file containing the urls that Velociraptor should grab. It should be a text file with one url per line.
This file will be split up and sent to each of the nodes. Fix the following option in the config file:
* urls_file="/the/absolute/path/to/your/urls.txt"

Decide how many nodes you want to run. More is faster, but your AWS account may be limited in the number of instances you can start.
Define both the number of instances and the availability zone where they should run in the config file:
* number_ec2_instances=3
* availability_zone="us-east-1"

Your workers will need an image that has awscli and parallel installed. The default image is public and works, feel free to use it.
To use the project default image, leave this line in the configuration file alone:
* ec2_image="ami-34dea15c"

To install and setup AWS CLI tools, run setup.sh. It will ask you for your AWS Keys. Use Keys that can at least launch EC2 Instances and assign IAM roles to them.
You can find an example minimum policy in examples/minimum-aws-group-policy.txt.

Now you're ready to run Velociraptor. It takes one argument which is your configuration file.

./Velociraptor example.cfg

Watch the nodes run and terminate themselves in your AWS EC2 Console. As they run and die you'll find the results in your S3 bucket.
Make sure they all die, otherwise you'll keep paying for them after the scrape is done.

You can view, manipulate, and download the contents of your bucket using the AWS CLI tools.

aws s3 ls s3://yourbucket-identifier/

This project is currently alpha and will probably continue to change quickly for a while.
If you plan on seriously using this, please contact me so we can coordinate a stable branch.

## Notes

In some places the program uses base64 encoding of the url as a filename. The recommendations in [RFC 3548](https://tools.ietf.org/html/rfc3548) were adhered to in order to make those encodings safe to
store on a Linux filesystem. Basically you just replace / character with the underscore _ and the + character with the minus - character. If you want to decode the filenames to the
urls, use tools that adhere to this RFC or do the simple transform on your own prior to decoding.

## License

Copyright (c) 2015, Eric Whyne
All rights reserved.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
