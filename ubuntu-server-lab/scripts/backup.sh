#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <source_directory>"
    exit 1
fi

SOURCE="$1"
BACKUP_DIR="/mnt/data/backups/automated"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)

if [ ! -d "$SOURCE" ]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

SOURCE=$(realpath -- "$SOURCE") || exit 1

if ! mountpoint -q /mnt/data; then
    echo "Error: Backup filesystem is not mounted."
    exit 1
fi

case "$BACKUP_DIR/" in
    "$SOURCE/"*|"$SOURCE"/*)
        echo "Error: Source contains the backup destination."
        exit 1
        ;;
esac

umask 077

mkdir -p "$BACKUP_DIR" || exit 1

SOURCE_NAME=$(basename "$SOURCE")
SOURCE_PARENT=$(dirname "$SOURCE")

ARCHIVE="$BACKUP_DIR/${SOURCE_NAME}-${TIMESTAMP}.tar.gz"

echo "Starting backup..."
echo "Source: $SOURCE"
echo "Destination: $ARCHIVE"

if tar -czf "$ARCHIVE" -C "$SOURCE_PARENT" -- "$SOURCE_NAME"; then
    echo "Backup created successfully."
else
    echo "Error: Backup failed."
    exit 1
fi

cd "$BACKUP_DIR" || exit 1

ARCHIVE_NAME=$(basename "$ARCHIVE")

if sha256sum "$ARCHIVE_NAME" > "$ARCHIVE_NAME.sha256" &&
   sha256sum -c "$ARCHIVE_NAME.sha256"; then
    echo "Integrity verification successful."
else
    echo "Error: Integrity verification failed."
    exit 1
fi

echo "Backup operation completed successfully."
exit 0
