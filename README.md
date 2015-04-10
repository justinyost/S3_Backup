# Backup Script

[![Software License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE.md)
[![Latest Version](https://img.shields.io/github/release/jtyost2/S3_Backup.svg?style=flat-square)](https://github.com/jtyost2/S3_Backup/releases)

This script runs and creates daily (stored for 7 days), weekly (stored for 28 days) and monthly (stored for 365 days) of a local webroot and complete database backup of [MySQL](http://www.mysql.com/), [PostgreSQL](http://www.postgresql.org/), [MongoDB](http://www.mongodb.org/) and [SQLite](https://www.sqlite.org/). Each is tared and gzipped and placed in a directory of your choosing and then optionally synched with an [Amazon S3 Bucket](http://aws.amazon.com/s3/) for off-site storage.

## Installation

- Manual
	- In your local directory type: `wget http://github.com/jtyost2/S3_Backup/zipball/master`
	- Unzip that download.

- Git Clone
	- In your local directory type: `git clone git://github.com/jtyost2/S3_Backup.git S3_Backup`

## Usage

### Prerequisite Tools

1. Command Line S3 Client: [http://s3tools.org/s3cmd](http://s3tools.org/s3cmd)
2. Optional AmazonS3 Bucket: [http://aws.amazon.com/s3/](http://aws.amazon.com/s3/)

### Setup

There is a batch of configuration settings needed to get this running. These are in the `config.sh.default` shell script and none of the them need to be in quotes (as far as I have tested). Copy and rename the `config.sh.default` to `config.sh` and set the values to your particular setup. Copy and rename the `tar_exclude.txt.default` to `tar_exclude.txt` and add any paths/files to be excluded from the tar backup to this file.

## Possible Issues When Using 

1. S3Cmd needs to be configured first before use
2. Recommend use case for running this is via a cron job, ensure the user the cron is running under has access to run the script and the correct permissions for access.

## Contributing

### Reporting Issues

Please use GitHub Issues for listing any known defects or issues

### Development

When working on this script, please fork and issue a PR for any new development.

### Reporting Issues

Please use [GitHub Isuses](https://github.com/jtyost2/S3_Backup/issues) for listing any known defects or issues.

## License ##

[MIT](https://github.com/jtyost2/S3_Backup/blob/master/LICENSE.md)

## Copyright ##

[Justin Yost](https://www.yostivanich.com/) 2015
