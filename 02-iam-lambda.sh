#!/usr/bin/env bash
# Tasks 4-6: least-privilege IAM role, Lambda, SQS -> Lambda mapping
set -euo pipefail; cd "$(dirname "$0")"; source env.sh

[[ "$(aws sns list-subscriptions-by-topic --topic-arn "$TOPIC_ARN" \
  --query 'Subscriptions[0].SubscriptionArn' --output text)" != PendingConfirmation ]] \
  || { echo "SNS subscription abhi confirm nahi hui."; exit 1; }

# Log group pre-created so the role doesn't need logs:CreateLogGroup
aws logs create-log-group --log-group-name "$LOG_GROUP"
aws logs put-retention-policy --log-group-name "$LOG_GROUP" --retention-in-days 7

# 4. IAM (policy template is rendered with envsubst; nothing account-specific is committed)
aws iam create-role --role-name "$ROLE" --assume-role-policy-document file://iam/trust-policy.json
aws iam put-role-policy --role-name "$ROLE" --policy-name file-notify-least-privilege \
  --policy-document "$(envsubst < iam/permissions-policy.json)"
sleep 10   # IAM propagation; if create-function says "role cannot be assumed", wait and re-run that command

# 5. Lambda
(cd lambda && zip -q ../function.zip index.mjs)
aws lambda create-function --function-name "$FN" --runtime nodejs22.x --handler index.handler \
  --role "$ROLE_ARN" --zip-file fileb://function.zip --timeout 10 \
  --environment "Variables={TOPIC_ARN=$TOPIC_ARN}"
aws lambda wait function-active-v2 --function-name "$FN"

# 6. SQS -> Lambda (partial batch responses: only failed messages are retried)
aws lambda create-event-source-mapping --function-name "$FN" --event-source-arn "$QUEUE_ARN" \
  --batch-size 5 --function-response-types ReportBatchItemFailures

echo "Mapping active hote hi 01 wala message process hoga. Email check karo."
