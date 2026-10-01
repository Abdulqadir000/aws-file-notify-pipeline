#!/usr/bin/env bash
# Deletes everything. Safe to re-run.
set -u; cd "$(dirname "$0")"; source env.sh

UUID="$(aws lambda list-event-source-mappings --function-name "$FN" --query 'EventSourceMappings[0].UUID' --output text)"
[[ "$UUID" != None ]] && aws lambda delete-event-source-mapping --uuid "$UUID"
aws lambda delete-function --function-name "$FN"
aws logs delete-log-group --log-group-name "$LOG_GROUP"
aws iam delete-role-policy --role-name "$ROLE" --policy-name file-notify-least-privilege
aws iam delete-role --role-name "$ROLE"
aws sns delete-topic --topic-arn "$TOPIC_ARN"   # also removes the subscription
aws sqs delete-queue --queue-url "$QUEUE_URL"
aws s3 rb "s3://$BUCKET" --force
rm -f function.zip sample.txt
