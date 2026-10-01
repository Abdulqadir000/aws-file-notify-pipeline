🚀 Built an event-driven file notification pipeline on AWS, using the CLI only (no console clicking, except the SNS email confirmation).

📦 S3 upload ➡️ SQS ➡️ Lambda ➡️ S3 (HeadObject) ➡️ SNS ➡️ Email

Upload a file, and within seconds an email arrives with its name, bucket, size, content type, last modified time, ETag and storage class.

🔧 What's inside
• S3, SQS and SNS created and wired up with AWS CLI
• Lambda (Node.js 22) triggered by an SQS event source mapping
• IAM role with least privilege: every statement scoped to a specific ARN
• Structured error logging in CloudWatch, with partial batch responses so only failed messages are retried

💡 Learnings
• `s3:GetObject` is what HeadObject needs, and without `s3:ListBucket` a missing key shows up as 403 instead of 404
• SQS visibility timeout must be longer than the Lambda timeout, or messages get processed twice
• `ReportBatchItemFailures` stops one bad message from re-running the whole batch
• Pre-creating the log group lets you drop `logs:CreateLogGroup` from the role
[Add 1-2 lines about a real challenge you hit while running it]

📸 [Attach: architecture diagram, S3 file, SQS message, email received, CloudWatch Logs]
🔗 Code, IAM policies and CLI scripts: [GitHub link]

All resources deleted afterwards 🧹

#AWS #Serverless #Lambda #SQS #SNS #S3 #CloudComputing #DevOps #IAM
