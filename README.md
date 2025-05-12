# 🛡️ IAM Automation Script with Mailjet Email Integration

This project is a **Bash scripting lab** designed to automate **Linux IAM (Identity and Access Management)** tasks such as:

- ✅ Creating users and groups from a CSV file
- ✅ Setting up secure passwords
- ✅ Enforcing password policies
- ✅ Assigning correct home directory permissions
- ✅ Sending email notifications via **Mailjet API**

---

## 📁 Project Structure

```
.
├── iam_setup.sh       # Main Bash script
├── users.txt          # Input CSV file (username, fullname, group)
├── .env               # Mailjet credentials (excluded from Git)
├── iam_setup.log      # Log file showing all script actions
├── README.md          # This documentation
```

---

## 📥 Prerequisites

- A Linux environment (EC2, VM, WSL, etc.)
- `jq` and `curl` installed
- Mailjet account with API keys
- `.env` file properly configured

---

## ⚙️ .env Configuration (DO NOT commit this file)

```
MAILJET_API_KEY=your_mailjet_api_key
MAILJET_SECRET_KEY=your_mailjet_secret
FROM_EMAIL=your_verified_sender@example.com
FROM_NAME="Your Company"
```

> ✅ **Tip:** Make sure `.env` is in your `.gitignore` to avoid pushing secrets.

---

## 📋 users.txt Format

Example structure:

```
username,fullname,group
jdoe,John Doe,marketing
asmith,Alice Smith,sales
mjones,Mike Jones,product
```

---

## 🚀 How to Run the Script

Make the script executable and run:

```bash
chmod +x iam_setup.sh
./iam_setup.sh
```

Or specify a custom file:

```bash
./iam_setup.sh custom_users.csv
```

---

## 📬 Email Notifications

Each user gets an email with:

- Their username
- A temporary password
- Instructions to reset password on first login

Emails are sent using the **Mailjet API**.

---

## 📝 Example Log Output

```
===== IAM Setup Log - Mon May 12 09:00:00 UTC 2025 =====
Processing user: jdoe
Group 'marketing' created.
User 'jdoe' created with group 'marketing'.
Temporary password set for 'jdoe'.
Password reset on next login enforced for 'jdoe'.
Set permissions for /home/jdoe to 700.
Email sent to jdoe@example.com
-----
```

---

## 🔒 Security Note

If you pushed your `.env` by mistake:

```bash
git rm --cached .env
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Remove .env and add to .gitignore"
```

⚠️ **Rotate your API keys** immediately if they were exposed.

---

## 🧠 What You Learn

- Linux IAM automation using Bash
- Script logging and security practices
- Sending transactional emails with Mailjet API
- Protecting secrets using `.env`

---

## 📌 License

This project is part of a DevOps learning challenge.  
Feel free to fork and improve it for your own use! 🚀
