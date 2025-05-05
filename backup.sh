#!/bin/bash

ACCESS_KEY=$S3_ACCESS_KEY_ID
SECRET_KEY=$S3_SECRET_ACCESS_KEY
REGION="ru-central-1"
HOST_BUCKET=$S3_BUCKET_NAME
HOST_BASE=$S3_ENDPOINT

cat > /home/backupuser/.s3cfg <<CONFIG
access_key = ${ACCESS_KEY}
secret_key = ${SECRET_KEY}
bucket_location = ${REGION}
host_base = ${HOST_BASE}
host_bucket = ${HOST_BUCKET}
gpg_passphrase = ${ENCRYPTION_PASSWORD}
CONFIG

PGPATHBACKUP=/opt/PGbackup
HISTORYBACKUP=14
DATEBACKUP=$(date "+%Y%m%d")
FILENAME=${PROJECT_NAME}_${POSTGRES_DB_NAME}_Postgres_${DATEBACKUP}.sql.gz.backup

echo 'Dumping Postgres...'
pg_dump -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -p ${POSTGRES_PORT} ${POSTGRES_DB_NAME} | gzip > ${PGPATHBACKUP}/${FILENAME}

echo 'Upload backup...'
s3cmd put ${PGPATHBACKUP}/${FILENAME} s3://$HOST_BUCKET/backups/${FILENAME}

echo "BACKUP COMPLETED!"

# echo 'Delete old backups...'
# s3cmd ls s3://$HOST_BUCKET/backups/ | grep ${PROJECT_NAME}_${POSTGRES_DB_NAME}_Postgres | awk '{print $4}' | sort | head -n -$HISTORYBACKUP | xargs s3cmd del || true
