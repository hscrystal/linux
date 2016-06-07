#!/bin/bash

### Set server settings
HOST="172.17.0.1"
TIMESTAMP=`date "+%Y-%m-%d"`
BACKUP_DIR="/opt/backup/$TIMESTAMP"
PATH_FILES="/opt/dti/files"
PATH_WEB="/opt/dti/web"
TEMP_FILES=$(mktemp -d /tmp/files.XXXXXXXX)
TEMP_WEB=$(mktemp -d /tmp/web.XXXXXXXX)

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
TEMP_MONGO=$(mktemp -d /tmp/mongo.XXXXXXXX)

[ ! -d $BACKUP_DIR ] && mkdir -p $BACKUP_DIR
[ ! -d $BACKUP_DIR ] && exit 1

### Backup Directory files
if [ -d "$PATH_FILES" ]; then
  rsync -a $PATH_FILES $TEMP_FILES
  #tar -czf $BACKUP_DIR/files.tar.gz -C $TEMP_FILES/ .
  tar -cjf $BACKUP_DIR/files.tar.bz2 -C $TEMP_FILES/ .
  [ -d $TEMP_FILES ] && rm -r $TEMP_FILES
  echo "!!!Backup Files Completed"
else
  echo "!!!=> Failed to Access Directory : $PATH_FILES"
fi

### Backup Directory web
if [ -d "$PATH_WEB" ]; then
  rsync -a $PATH_WEB $TEMP_WEB
  #tar -czf $BACKUP_DIR/web.tar.gz -C $TEMP_WEB/ .
  tar -cjf $BACKUP_DIR/web.tar.bz2 -C $TEMP_WEB/ .
  [ -d $TEMP_WEB ] && rm -r $TEMP_WEB
  echo "!!!Backup Web Completed"
else
  echo "!!!=> Failed to Access Directory : $PATH_WEB"
fi

### Backup MYSQL DB
if which mysqldump >/dev/null; then
  #mysqldump --routines --events -h $HOST -P $PORT_MYSQL -u $USER_MYSQL -p$PASS_MYSQL --all-databases | gzip -9 > $BACKUP_DIR/mysql.sql.gz
  mysqldump --routines --events -h $HOST -P $PORT_MYSQL -u $USER_MYSQL -p$PASS_MYSQL --all-databases | bzip2 > $BACKUP_DIR/mysql.sql.bz2
  if [ $? -ne 0 ]; then
      echo "!!!Failed Mysqldump to Backup"
  else
      echo "!!!Backup MYSQL Completed"
  fi
else
  echo "!!!=> Failed does not exist mysqldump"
fi

### Backup MONGO DB
if which mongodump >/dev/null; then
  mongodump --host $HOST --port $PORT_MONGO --authenticationDatabase $AUTH_DB -u $USER_MONGO -p $PASS_MONGO -d $DB_MONGO --out $TEMP_MONGO/ >/dev/null 2>&1
  if [ $? -ne 0 ]; then
      echo "!!!Failed Mongodump to Backup"
  fi
  #tar -czf $BACKUP_DIR/mongo.tar.gz -C $TEMP_MONGO/ .
  tar -cjf $BACKUP_DIR/mongo.tar.bz2 -C $TEMP_MONGO/ .
  [ -d $TEMP_MONGO ] && rm -rf $TEMP_MONGO
  echo "!!!Backup MONGO Completed"
else
  echo "!!!=> Failed does not exist mongodump"
fi
