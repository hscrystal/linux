#!/bin/bash

### Set server settings
HOST="172.17.0.1"
TIMESTAMP=`date "+%Y-%m-%d"`
BACKUP_DIR="/opt/backup/$TIMESTAMP"
PATH_FILES="/opt/dti/files"
PATH_WEB="/opt/dti/web"
TEMP_FILES="/tmp/files"
TEMP_WEB="/tmp/web"

### Setting Mysql
USER_MYSQL="root"
PASS_MYSQL="mozermysqlrootpassword"
PORT_MYSQL="4306"

### Setting Mongo
USER_MONGO="mozer"
PASS_MONGO="mozermongopassword"
PORT_MONGO="4717"
AUTH_DB="mozer"
DB_MONGO="mozer"
TEMP_MONGO="/tmp/mongo"

[ ! -d $BACKUP_DIR ] && mkdir -p $BACKUP_DIR || :

if [ -d "$BACKUP_DIR" ]; then

	### Backup Directory files
	if [ -d "$PATH_FILES" ]; then
		rsync -a $PATH_FILES $TEMP_FILES
		tar -czf $BACKUP_DIR/files.tar.gz -C $TEMP_FILES/ .
		[ -d $TEMP_FILES ] && rm -r $TEMP_FILES
		echo "!!!Backup Files complete"
	else
		echo "!!!=> Failed to Access Directory : $PATH_FILES"
	fi

	### Backup Directory web
        if [ -d "$PATH_WEB" ]; then
                rsync -a $PATH_WEB $TEMP_WEB
                tar -czf $BACKUP_DIR/web.tar.gz -C $TEMP_WEB/ .
                [ -d $TEMP_WEB ] && rm -r $TEMP_WEB
                echo "!!!Backup Web complete"
        else
                echo "!!!=> Failed to Access Directory : $PATH_WEB"
        fi

	### Backup MYSQL DB
        #if [ -d "$PATH_MYSQL" ]; then
        if which mysqldump >/dev/null; then
		mysqldump --routines --events -h $HOST -P $PORT_MYSQL -u $USER_MYSQL -p$PASS_MYSQL --all-databases | gzip -9 > $BACKUP_DIR/mysql.sql.gz
		echo "!!!Backup MYSQL complete"
        else
                echo "!!!=> Failed does not exist mysqldump"
        fi

	### Backup MONGO DB
        if which mongodump >/dev/null; then
		mongodump --host $HOST --port $PORT_MONGO --authenticationDatabase $AUTH_DB -u $USER_MONGO -p $PASS_MONGO -d $DB_MONGO --out $TEMP_MONGO/
		tar -czf $BACKUP_DIR/mongo.tar.gz -C $TEMP_MONGO/ .
		[ -d $TEMP_MONGO ] && rm -rf $TEMP_MONGO
                echo "!!!Backup MONGO complete"
        else
                echo "!!!=> Failed does not exist mongodump"
        fi
else
	echo "!!!=> Failed to create backup path: $BACKUP_DIR"
fi
