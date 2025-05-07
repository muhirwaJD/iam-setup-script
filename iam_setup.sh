#!/bin/bash

# File paths
INPUT_FILE="users.txt"
LOG_FILE="iam_setup.log"
DEFAULT_PASSWORD="ChangeMe123"

# Create or clear the log file
echo "===== IAM Setup Log - $(date) =====" > "$LOG_FILE"

# Check if the input file exists
if [[ ! -f $INPUT_FILE ]]; then
  echo "ERROR: $INPUT_FILE not found!" | tee -a "$LOG_FILE"
  exit 1
fi

# Process each line of the input file
while IFS=',' read -r username fullname groupname; do
  echo "Processing user: $username" | tee -a "$LOG_FILE"

  # 1. Create group if it doesn't exist
  if ! getent group "$groupname" > /dev/null; then
    groupadd "$groupname"
    echo "Group '$groupname' created." | tee -a "$LOG_FILE"
  else
    echo "Group '$groupname' already exists." | tee -a "$LOG_FILE"
  fi

  # 2. Create user if it doesn't exist
  if ! id "$username" &> /dev/null; then
    useradd -m -c "$fullname" -g "$groupname" "$username"
    echo "User '$username' created with group '$groupname'." | tee -a "$LOG_FILE"

    # Set temporary password
    echo "$username:$DEFAULT_PASSWORD" | chpasswd
    echo "Temporary password set for '$username'." | tee -a "$LOG_FILE"

    # Force password change on next login
    chage -d 0 "$username"
    echo "Forced password reset on next login for '$username'." | tee -a "$LOG_FILE"

    # Set home directory permissions
    chmod 700 "/home/$username"
    echo "Permissions set for /home/$username to 700." | tee -a "$LOG_FILE"

  else
    echo "User '$username' already exists. Skipping creation." | tee -a "$LOG_FILE"
  fi

  echo "-----" | tee -a "$LOG_FILE"

done < "$INPUT_FILE"

echo "IAM setup completed at $(date)." | tee -a "$LOG_FILE"

