#Backup Script#

This script runs and creates daily (stored for 7 days), weekly (stored for 28 days) and monthly (stored for 365 days) of a local webroot and complete database backup of [MySQL](http://www.mysql.com/), [PostgreSQL](http://www.postgresql.org/) and [MongoDB](http://www.mongodb.org/). Each is tared and gzipped and placed in a directory of your choosing and then synched with an [Amazon S3 Bucket](http://aws.amazon.com/s3/) for off-site storage.

##Config Settings and Setup##

There is a batch of config settings needed to get this running. These are in the `config.sh.default` shell script and none of the them need to be in quotes (as far as I have tested). Copy and rename the `config.sh.default` to `config.sh` and set the values to your particular setup. Copy and rename the `tar_exclude.txt.default` to `tar_exclude.txt` and add any paths/files to be excluded from the tar backup to this file.

##Needed Tools##
1. Command Line S3 Client: [http://s3tools.org/s3cmd](http://s3tools.org/s3cmd)
2. AmazonS3 Bucket: [http://aws.amazon.com/s3/](http://aws.amazon.com/s3/)

##Installation##
- Manual
	- In your local directory type: `wget http://github.com/jtyost2/S3_Backup/zipball/master`
	- Unzip that download.

- Git Clone
	- In your local directory type: `git clone git://github.com/jtyost2/S3_Backup.git S3_Backup`
		
##To Do##
1. Add additional database backups

##Possible Issues##
1. S3Cmd needs to be configured first before use 