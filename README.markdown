<h1>Backup Script</h1>

<p>This script runs and creates daily (stored for 7 days), weekly (stored for 28 days) and monthly (stored for 365 days) of a local webroot and complete database backup of MySQL, PostgreSQL and MongoDB. Each is tared and gzipped and placed in a directory of your choosing and then synched with an Amazon S3 Bucket for off-site storage.</p>

<h2>Config Settings</h2>

<p>There is a batch of config settings needed to get this running. These are at the top of the shell script and none of the them need to be in quotes (as far as I have tested)</p>

<ol>
	<li>MYSQL_DB_PASSWORD</li>
	<li>WEBROOT_LOCAL_PATH</li>
	<li>BACKUP_LOCAL_PATH</li>
	<li>AMAZON_S3_PATH</li>
</ol>

<h2>Needed Command Line Tools</h2>

<ul>
	<li><a href="http://s3tools.org/s3cmd" title="Command Line S3 Client">Command Line S3 Client</a></li>
</ul>