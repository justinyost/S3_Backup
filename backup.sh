#!/bin/sh

#Local Settings and Options
MYSQL_DB_PASSWORD=ThisIsYourMySQLRootPassword
WEBROOT_LOCAL_PATH=/path/to/your/local/webroot
BACKUP_LOCAL_PATH=/path/to/where/your/backups/will/be/locally
AMAZON_S3_PATH=s3://BucketName/folder_in_bucket/

#DateTimeString
THEDATE=`date +%Y_%m_%d_%H_%M`

#Dump Databases for Daily DB Backups
mysqldump --add-drop-table --all-databases --user=root --password=$MYSQL_DB_PASSWORD | gzip -9 > ${BACKUP_LOCAL_PATH}daily_db_backup_mysql_$THEDATE.sql.gz
pg_dumpall | gzip -9 > ${BACKUP_LOCAL_PATH}daily_db_backup_postgresql_$THEDATE.sql.gz
mongodump --host localhost | gzip -9 > ${BACKUP_LOCAL_PATH}daily_db_backup_mongodb_$THEDATE.sql.gz

#Find and delete old daily database backups that are over a week old
find ${BACKUP_LOCAL_PATH}daily_db_backup_* -mtime +7 -exec rm -f {} \;

#Tar and Gzip WWW Folder for Daily Backup
tar -cf ${BACKUP_LOCAL_PATH}daily_site_backup_$THEDATE.tar ${WEBROOT_LOCAL_PATH}
gzip -9 ${BACKUP_LOCAL_PATH}daily_site_backup_$THEDATE.tar

#Find and delete old daily site backups that are over a week old
find ${BACKUP_LOCAL_PATH}daily_site_backup_* -mtime +7 -exec rm -f {} \;

if [ `date +%u` = 1 ]
then
	#Dump Databases for Weekly DB Backups
	mysqldump --add-drop-table --all-databases --user=root --password=$MYSQL_DB_PASSWORD | gzip -9 > ${BACKUP_LOCAL_PATH}weekly_db_backup_mysql_$THEDATE.sql.gz
	pg_dumpall | gzip -9 > ${BACKUP_LOCAL_PATH}weekly_db_backup_postgresql_$THEDATE.sql.gz
	mongodump --host localhost | gzip -9 > ${BACKUP_LOCAL_PATH}weekly_db_backup_mongodb_$THEDATE.sql.gz
	
	#Find and delete old weekly database backups that are over 4 weeks old
	find ${BACKUP_LOCAL_PATH}weekly_db_backup_* -mtime +28 -exec rm -f {} \;
	
	#Tar and Gzip WWW Folder for Weekly Backup
	tar -cf ${BACKUP_LOCAL_PATH}weekly_site_backup_$THEDATE.tar ${WEBROOT_LOCAL_PATH}
	gzip -9 ${BACKUP_LOCAL_PATH}weekly_site_backup_$THEDATE.tar
	
	#Find and delete old daily site backups that are over 4 weeks old
	find ${BACKUP_LOCAL_PATH}weekly_site_backup_* -mtime +28 -exec rm -f {} \;
fi

if [ `date +%d` = 01 ]
then
	#Dump Databases for Monthly DB Backups
	mysqldump --add-drop-table --all-databases --user=root --password=$MYSQL_DB_PASSWORD | gzip -9 > ${BACKUP_LOCAL_PATH}monthly_db_backup_mysql_$THEDATE.sql.gz
	pg_dumpall | gzip -9 > ${BACKUP_LOCAL_PATH}monthly_db_backup_postgresql_$THEDATE.sql.gz
	mongodump --host localhost | gzip -9 > ${BACKUP_LOCAL_PATH}monthly_db_backup_mongodb_$THEDATE.sql.gz
	
	#Find and delete old monthly database backups that are over 1 year old
	find ${BACKUP_LOCAL_PATH}monthly_db_backup_* -mtime +356 -exec rm -f {} \;
	
	#Tar and Gzip WWW Folder for monthly Backup
	tar -cf ${BACKUP_LOCAL_PATH}monthly_site_backup_$THEDATE.tar ${WEBROOT_LOCAL_PATH}
	gzip -9 ${BACKUP_LOCAL_PATH}monthly_site_backup_$THEDATE.tar
	
	#Find and delete old monthly site backups that are over 1 year old
	find ${BACKUP_LOCAL_PATH}monthly_site_backup_* -mtime +356 -exec rm -f {} \;
fi

#S3 Sync
s3cmd sync --delete-removed ${BACKUP_LOCAL_PATH} $AMAZON_S3_PATH