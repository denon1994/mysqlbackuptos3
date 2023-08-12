#!/bin/bash
# Created by Dinuka Nanayakkara(denon1994)(https://github.com/denon1994)

# Set your database credentials
DB_USER=""
DB_PASS=""
DB_NAME=""

# Set AWS credentials
AWS_ACCESS_KEY=""
AWS_SECRET_KEY=""
S3_BUCKET=""

# Set backup directory and filename
BACKUP_DIR="/path/to/backup/directory"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_FILENAME="backup_${TIMESTAMP}.sql"

# Set log file path
LOG_FILE="/var/log/backup_log.log"

# Function to log messages
log_message() {
    local message="$1"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

# Log start of backup process
log_message "Starting database backup process."

# Create the backup
mysqldump -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" > "${BACKUP_DIR}/${BACKUP_FILENAME}"

# Check if the backup was successful
if [ $? -eq 0 ]; then
    log_message "Database backup created successfully."
else
    log_message "Error creating database backup."
    exit 1
fi

# Use AWS CLI to upload the backup to S3
aws configure set aws_access_key_id "${AWS_ACCESS_KEY}"
aws configure set aws_secret_access_key "${AWS_SECRET_KEY}"
aws s3 cp "${BACKUP_DIR}/${BACKUP_FILENAME}" "s3://${S3_BUCKET}/${BACKUP_FILENAME}"

# Check if the upload was successful
if [ $? -eq 0 ]; then
    log_message "Backup uploaded to S3 successfully."
else
    log_message "Error uploading backup to S3."
    exit 1
fi

# Clean up - remove the local backup file
rm "${BACKUP_DIR}/${BACKUP_FILENAME}"

log_message "Backup process completed."
