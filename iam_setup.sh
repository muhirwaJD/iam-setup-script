#!/bin/bash

# Load secrets from .env file
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
else
  echo "Missing .env file"
  exit 1
fi

# File paths and defaults
INPUT_FILE="${1:-users.txt}"
LOG_FILE="iam_setup.log"
DEFAULT_PASSWORD="ChangeMe123"

# Clear previous log
echo "===== IAM Setup Log - $(date) =====" > "$LOG_FILE"

# Check input file exists
if [[ ! -f $INPUT_FILE ]]; then
  echo "ERROR: $INPUT_FILE not found!" | tee -a "$LOG_FILE"
  exit 1
fi

# Process each user entry
while IFS=',' read -r username fullname groupname email; do
  # Skip bad lines
  if [[ -z "$username" || -z "$fullname" || -z "$groupname" || -z "$email" ]]; then
    continue
  fi

  echo "Processing user: $username" | tee -a "$LOG_FILE"

  # Create group if missing
  if ! getent group "$groupname" > /dev/null; then
    groupadd "$groupname"
    echo "Group '$groupname' created." | tee -a "$LOG_FILE"
  fi

  # Create user if missing
  if ! id "$username" &>/dev/null; then
    useradd -m -c "$fullname" -g "$groupname" "$username"
    echo "$username:$DEFAULT_PASSWORD" | chpasswd
    chage -d 0 "$username"
    chmod 700 "/home/$username"
    echo "User '$username' created and secured." | tee -a "$LOG_FILE"

    # Send email via Mailjet
    curl -s \
      --user "$MAILJET_API_KEY:$MAILJET_SECRET_KEY" \
      https://api.mailjet.com/v3.1/send \
      -H "Content-Type: application/json" \
      -d "{
        \"Messages\": [{
          \"From\": {
            \"Email\": \"$FROM_EMAIL\",
            \"Name\": \"$FROM_NAME\"
          },
          \"To\": [{
            \"Email\": \"$email\",
            \"Name\": \"$fullname\"
          }],
          \"Subject\": \"Your Linux Account Info\",
          \"TextPart\": \"Hi $fullname,\n\nYour account '$username' has been created.\nTemporary password: $DEFAULT_PASSWORD\n\nPlease change it after your first login.\n\n– Admin\"
        }]
      }" > /dev/null

    echo "Email sent to $email." | tee -a "$LOG_FILE"
  else
    echo "User '$username' already exists. Skipping." | tee -a "$LOG_FILE"
  fi

  echo "-----" | tee -a "$LOG_FILE"
done < "$INPUT_FILE"

echo "IAM setup completed at $(date)." | tee -a "$LOG_FILE"

