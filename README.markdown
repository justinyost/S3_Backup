<h1>Backup Script</h1>

<p>This script runs and creates daily (stored for 7 days), weekly (stored for 28 days) and monthly (stored for 365 days) of a local webroot and complete database backup of MySQL, PostgreSQL and MongoDB. Each is tar.gz and placed in a directory of your choosing and then synched with an Amazon S3 Bucket for off-site storage.</p>

<h2>Config Settings</h2>

<p>There is a batch of config settings needed to get this running</p>

<ol>
	<li>MYSQL_DB_PASSWORD</li>
	<li>WEBROOT_LOCAL_PATH</li>
	<li>BACKUP_LOCAL_PATH</li>
	<li>AMAZON_S3_PATH</li>
</ol>