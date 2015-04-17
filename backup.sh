#!/usr/bin/env bash

#---------------------------------------------------------------------
usage () {
	cat <<EOT
${0##*/}
	Backup a directory, MySQL, PostgreSQL, MongoDB and SQLite databases
	using a rotating scheme of daily, weekly and monthly backups.

	To use, move the config.sh.default included in the repo to config.sh
	and edit the various settings as need.

	When it runs for each feature turned on:
	* Creates the backup
	* Moves to the BACKUP_LOCAL_PATH folder
	* Names the backup as daily_db_backup_${TOOL_BEING_BACKED_UP}....
	* If it is 1st day of the week, copys it to
	weekly_${TOOL_BEING_BACKED_UP}....
	* If it is 1st day of the month, copys it to
	monthly_${TOOL_BEING_BACKED_UP}.....
	* Daily backups that are older than a week are deleted
	* Weekly backups that are older than a 28 days (4 weeks) are deleted
	* Monthly backups that are older than a 365 days (1 year) are deleted
	* If the AMAZON_S3_UPLOAD_ACTIVE is set to true, the BACKUP_LOCAL_PATH
	folder is synched with a S3 Bucket

Requires:
	S3 Command Line Tools installed: http://s3tools.org/s3cmd

Usage:
	${0##*/}

Bash Variables Set From "config.sh":
	# MySQL Settings
	MYSQL_DB_USERNAME=ThisIsYourMySQLUsername
	MYSQL_DB_PASSWORD=ThisIsYourMySQLRootPassword

	# PostgreSQL Settings
	POSTGRES_DB_USERNAME=ThisIsYourPostgresUsername

	# MongoDB Settings
	MONGO_DB_USERNAME=ThisIsYourMongoDBUsername
	MONGO_DB_PASSWORD=ThisIsYourMongoDBPassword

	# SQLite Settings
	SQLITE_PATH=/Users/jtyost2/Sites/jtyost2/S3_Backup/testing

	# Webroot Backup Settings
	WEBROOT_LOCAL_PATH=/Users/jtyost2/Desktop
	BACKUP_LOCAL_PATH=/Users/jtyost2/Sites/jtyost2/testing_dump/
	AMAZON_S3_PATH=s3://BucketName/folder_in_bucket/

	# Turn on or off features
	MYSQL_DUMP_ACTIVE=false
	POSTGRESQL_DUMP_ACTIVE=false
	MONGODB_DUMP_ACTIVE=false
	SQLITE_DUMP_ACTIVE=true
	AMAZON_S3_UPLOAD_ACTIVE=false
EOT

	exit ${1:-0}  # Exit with code 0 unless an arg is passed to the method.
}
if [ "$1" = '-h' ]; then
	usage
fi

#Import settings from ./config.sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/config.sh

#DateTimeString
THEDATE=`date +%Y_%m_%d_%H_%M`

#Dump Databases for Daily DB Backups
if ${MYSQL_DUMP_ACTIVE};
then
	mysqldump --add-drop-table --all-databases --user=${MYSQL_DB_USERNAME} --password=${MYSQL_DB_PASSWORD} | gzip -9 > ${BACKUP_LOCAL_PATH}daily_db_backup_mysql_${THEDATE}.sql.gz
fi
if ${POSTGRESQL_DUMP_ACTIVE};
then
	pg_dumpall --username=${POSTGRES_DB_USERNAME} | gzip -9 > ${BACKUP_LOCAL_PATH}daily_db_backup_postgresql_${THEDATE}.sql.gz
fi
if ${MONGODB_DUMP_ACTIVE};
then
	mongodump --host localhost --username ${MONGO_DB_USERNAME} --password ${MONGO_DB_PASSWORD} | gzip -9 > ${BACKUP_LOCAL_PATH}daily_db_backup_mongodb_${THEDATE}.sql.gz
fi
if ${SQLITE_DUMP_ACTIVE};
then
	gzip -9 < ${SQLITE_PATH} > ${BACKUP_LOCAL_PATH}daily_db_backup_sqlite_${THEDATE}.gz
fi

#Tar and Gzip WWW Folder for Daily Backup
tar -cf ${BACKUP_LOCAL_PATH}daily_site_backup_${THEDATE}.tar -X ${DIR}/tar_exclude.txt ${WEBROOT_LOCAL_PATH}
gzip -9 ${BACKUP_LOCAL_PATH}daily_site_backup_${THEDATE}.tar

#Find and delete old daily site backups that are over a week old
find ${BACKUP_LOCAL_PATH}daily_site_backup_* -mtime +7 -exec rm -f {} \;

#Find and delete old daily database backups that are over a week old
find ${BACKUP_LOCAL_PATH}daily_db_backup_* -mtime +7 -exec rm -f {} \;

if [ `date +%u` = 1 ]
then
	#Copy Daily Database Backup for Weekly DB Backups
	if ${MYSQL_DUMP_ACTIVE};
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_mysql_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}weekly_db_backup_mysql_${THEDATE}.sql.gz
	fi
	if ${POSTGRESQL_DUMP_ACTIVE};
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_postgresql_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}weekly_db_backup_postgresql_${THEDATE}.sql.gz
	fi
	if ${MONGODB_DUMP_ACTIVE};
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_mongodb_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}weekly_db_backup_mongodb_${THEDATE}.sql.gz
	fi
	if ${SQLITE_DUMP_ACTIVE};
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_sqlite_${THEDATE}.gz ${BACKUP_LOCAL_PATH}weekly_db_backup_sqlite_${THEDATE}.gz
	fi

	#Copy Daily Webroot Backup for Weekly Backup
	cp ${BACKUP_LOCAL_PATH}daily_site_backup_${THEDATE}.tar.gz ${BACKUP_LOCAL_PATH}weekly_site_backup_${THEDATE}.tar.gz

	#Find and delete old daily site backups that are over 4 weeks old
	find ${BACKUP_LOCAL_PATH}weekly_site_backup_* -mtime +28 -exec rm -f {} \;

	#Find and delete old daily database backups that are over 4 weeks old
	find ${BACKUP_LOCAL_PATH}weekly_db_backup_* -mtime +28 -exec rm -f {} \;
fi

if [ `date +%d` = 01 ]
then
	#Copy Daily Database Backup for Monthly DB Backups
	if ${MYSQL_DUMP_ACTIVE};
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_mysql_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}monthly_db_backup_mysql_${THEDATE}.sql.gz
	fi
	if ${POSTGRESQL_DUMP_ACTIVE};
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_postgresql_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}monthly_db_backup_postgresql_${THEDATE}.sql.gz
	fi
	if ${MONGODB_DUMP_ACTIVE};
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_mongodb_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}monthly_db_backup_mongodb_${THEDATE}.sql.gz
	fi
	if ${SQLITE_DUMP_ACTIVE};
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_sqlite_${THEDATE}.gz ${BACKUP_LOCAL_PATH}monthly_db_backup_sqlite_${THEDATE}.gz
	fi

	#Copy Daily Webroot Backup for Monthly Backup
	cp ${BACKUP_LOCAL_PATH}daily_site_backup_${THEDATE}.tar.gz ${BACKUP_LOCAL_PATH}monthly_site_backup_${THEDATE}.tar.gz

	#Find and delete old monthly site backups that are over 1 year old
	find ${BACKUP_LOCAL_PATH}monthly_site_backup_* -mtime +356 -exec rm -f {} \;

	#Find and delete old monthly database backups that are over 1 year old
	find ${BACKUP_LOCAL_PATH}monthly_db_backup_* -mtime +356 -exec rm -f {} \;
fi

#S3 Sync
if ${AMAZON_S3_UPLOAD_ACTIVE};
then
	s3cmd sync --delete-removed ${BACKUP_LOCAL_PATH} ${AMAZON_S3_PATH}
fi

echo "S3Backup Completed For: ${THEDATE}" >&2
