#!/usr/bin/env bash

#Import settings from ./config.sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/config.sh

#DateTimeString
THEDATE=`date +%Y_%m_%d_%H_%M`

#Dump Databases for Daily DB Backups
if $MYSQL_DUMP_ACTIVE;
then
	mysqldump --add-drop-table --all-databases --user=${MYSQL_DB_USERNAME} --password=${MYSQL_DB_PASSWORD} | gzip -9 > ${BACKUP_LOCAL_PATH}daily_db_backup_mysql_${THEDATE}.sql.gz
fi
if $POSTGRESQL_DUMP_ACTIVE;
then
	pg_dumpall --username=${POSTGRES_DB_USERNAME} | gzip -9 > ${BACKUP_LOCAL_PATH}daily_db_backup_postgresql_${THEDATE}.sql.gz
fi
if $MONGODB_DUMP_ACTIVE;
then
	mongodump --host localhost --username ${MONGO_DB_USERNAME} --password ${MONGO_DB_PASSWORD} | gzip -9 > ${BACKUP_LOCAL_PATH}daily_db_backup_mongodb_${THEDATE}.sql.gz
fi

#Find and delete old daily database backups that are over a week old
find ${BACKUP_LOCAL_PATH}daily_db_backup_* -mtime +7 -exec rm -f {} \;

#Tar and Gzip WWW Folder for Daily Backup
tar -cf ${BACKUP_LOCAL_PATH}daily_site_backup_${THEDATE}.tar -X ${DIR}/tar_exclude.txt ${WEBROOT_LOCAL_PATH}
gzip -9 ${BACKUP_LOCAL_PATH}daily_site_backup_${THEDATE}.tar

#Find and delete old daily site backups that are over a week old
find ${BACKUP_LOCAL_PATH}daily_site_backup_* -mtime +7 -exec rm -f {} \;

if [ `date +%u` = 1 ]
then
	#Copy Daily Database Backup for Weekly DB Backups
	if $MYSQL_DUMP_ACTIVE;
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_mysql_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}weekly_db_backup_mysql_${THEDATE}.sql.gz
	fi
	if $POSTGRESQL_DUMP_ACTIVE;
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_postgresql_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}weekly_db_backup_postgresql_${THEDATE}.sql.gz
	fi
	if $MONGODB_DUMP_ACTIVE;
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_mongodb_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}weekly_db_backup_mongodb_${THEDATE}.sql.gz
	fi
	
	#Find and delete old weekly database backups that are over 4 weeks old
	find ${BACKUP_LOCAL_PATH}weekly_db_backup_* -mtime +28 -exec rm -f {} \;
	
	#Copy Daily Webroot Backup for Weekly Backup
	cp ${BACKUP_LOCAL_PATH}daily_site_backup_${THEDATE}.tar.gz ${BACKUP_LOCAL_PATH}weekly_site_backup_${THEDATE}.tar.gz
	
	#Find and delete old daily site backups that are over 4 weeks old
	find ${BACKUP_LOCAL_PATH}weekly_site_backup_* -mtime +28 -exec rm -f {} \;
fi

if [ `date +%d` = 01 ]
then
	#Copy Daily Database Backup for Monthly DB Backups
	if $MYSQL_DUMP_ACTIVE;
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_mysql_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}monthly_db_backup_mysql_${THEDATE}.sql.gz
	fi
	if $POSTGRESQL_DUMP_ACTIVE;
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_postgresql_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}monthly_db_backup_postgresql_${THEDATE}.sql.gz
	fi
	if $MONGODB_DUMP_ACTIVE;
	then
		cp ${BACKUP_LOCAL_PATH}daily_db_backup_mongodb_${THEDATE}.sql.gz ${BACKUP_LOCAL_PATH}monthly_db_backup_mongodb_${THEDATE}.sql.gz
	fi
	
	#Find and delete old monthly database backups that are over 1 year old
	find ${BACKUP_LOCAL_PATH}monthly_db_backup_* -mtime +356 -exec rm -f {} \;
	
	#Copy Daily Webroot Backup for Monthly Backup
	cp ${BACKUP_LOCAL_PATH}daily_site_backup_${THEDATE}.tar.gz ${BACKUP_LOCAL_PATH}monthly_site_backup_${THEDATE}.tar.gz
	
	#Find and delete old monthly site backups that are over 1 year old
	find ${BACKUP_LOCAL_PATH}monthly_site_backup_* -mtime +356 -exec rm -f {} \;
fi

#S3 Sync
s3cmd sync --delete-removed ${BACKUP_LOCAL_PATH} $AMAZON_S3_PATH

echo "S3Backup Completed For: ${THEDATE}"