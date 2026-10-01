#!/usr/bin/env bash
# Tasks 1-3: S3 + upload, SQS + message, SNS + email subscription
set -euo pipefail; cd "$(dirname "$0")"; source env.sh
: "${EMAIL:?run: export EMAIL=you@example.com}"

# 1. S3
aws s3 mb "s3://$BUCKET" --region "$REGION"
echo "Hello from the AWS CLI pipeline" > sample.txt
aws s3 cp sample.txt "s3://$BUCKET/$KEY"

# 2. SQS (visibility timeout >= Lambda timeout) + message
aws sqs create-queue --queue-name "$QUEUE" --attributes VisibilityTimeout=60
aws sqs send-message --queue-url "$QUEUE_URL" \
  --message-body "$(printf '{"bucket":"%s","key":"%s"}' "$BUCKET" "$KEY")"

# 3. SNS + email subscription
aws sns create-topic --name "$TOPIC"
aws sns subscribe --topic-arn "$TOPIC_ARN" --protocol email --notification-endpoint "$EMAIL"

echo "Inbox mein 'AWS Notification - Subscription Confirmation' email ka Confirm link click karo, phir ./02-iam-lambda.sh chalao."
