#!/bin/bash

# File paths and defaults
INPUT_FILE="${1:-users.txt}"
LOG_FILE="iam_setup.log"
DEFAULT_PASSWORD="ChangeMe123"
MAIL_SENDER="admin@localhost"

# Create or clear the log file
echo "===== IAM Setup Log - $(date) =====" > "$LOG_FILE"

# Check if the input file exists
if [[ ! -f $INPUT_FILE ]]; then
  echo "ERROR: $INPUT_FILE not found!" | tee -a "$LOG_FILE"
  exit 1
fi

# Process each line of the input file
while IFS=',' read -r username fullname groupname; do
	# Skip empty or incomplete lines
	if [[ -z "$username" || -z "$fullname" || -z "$groupname" ]]; then
	  continue
	fi
	
  echo "Processing user: $username" | tee -a "$LOG_FILE"
  # Create group if it doesn't exist
  if ! getent group "$groupname" > /dev/null; then
    groupadd "$groupname"
    echo "Group '$groupname' created." | tee -a "$LOG_FILE"
  else
    echo "Group '$groupname' already exists." | tee -a "$LOG_FILE"
  fi

  # Create user if it doesn't exist
  if ! id "$username" &> /dev/null; then
    useradd -m -c "$fullname" -g "$groupname" "$username"
    echo "User '$username' created with group '$groupname'." | tee -a "$LOG_FILE"

    # Set a secure temporary password
    echo "$username:$DEFAULT_PASSWORD" | chpasswd
    echo "Temporary password set for '$username'." | tee -a "$LOG_FILE"

    # Force password change at next login
    chage -d 0 "$username"
    echo "Password reset on next login enforced for '$username'." | tee -a "$LOG_FILE"

    # Set home dir permissions
    chmod 700 "/home/$username"
    echo "Set permissions for /home/$username to 700." | tee -a "$LOG_FILE"

    # Send email notification
    echo "Hello $fullname,

Your account '$username' has been created on the system.
Please use the following temporary password to log in: $DEFAULT_PASSWORD

Make sure to change it immediately after login.

Thanks,
Admin" | mail -s "Your New Linux Account Info" -r "$MAIL_SENDER" "$username@localhost"

    echo "Notification email sent to $username@localhost." | tee -a "$LOG_FILE"
  else
    echo "User '$username' already exists. Skipping creation." | tee -a "$LOG_FILE"
  fi

  echo "-----" | tee -a "$LOG_FILE"
done < "$INPUT_FILE"

echo "IAM setup completed at $(date)." | tee -a "$LOG_FILE"

