#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Error: Run this script with sudo."
    exit 1
fi

if [ "$#" -ne 2 ]; then
    echo "Usage: sudo $0 <username> <department>"
    exit 1
fi

USERNAME="$1"
DEPARTMENT="$2"

if [[ ! "$USERNAME" =~ ^[a-z][a-z0-9_-]{0,31}$ ]] ||
   [[ ! "$DEPARTMENT" =~ ^[a-z][a-z0-9_-]{0,31}$ ]]; then
    echo "Error: Invalid username or department."
    exit 1
fi

if id "$USERNAME" > /dev/null 2>&1; then
    echo "Error: User '$USERNAME' already exists."
    exit 1
fi

if ! getent group "$DEPARTMENT" > /dev/null; then
    groupadd "$DEPARTMENT" || exit 1
    echo "Department group created: $DEPARTMENT"
else
    echo "Department group already exists."
fi

if ! useradd -m -s /bin/bash -G "$DEPARTMENT" "$USERNAME"; then
    echo "Error: User creation failed."
    exit 1
fi

echo "Set the initial password for $USERNAME"

if ! passwd "$USERNAME"; then
    passwd -l "$USERNAME"
    echo "Error: Password setup failed."
    echo "The account requires administrator review."
    exit 1
fi

passwd -e "$USERNAME" || exit 1

echo "Employee account created successfully."
echo "Username: $USERNAME"
echo "Department: $DEPARTMENT"

id "$USERNAME"

exit 0
