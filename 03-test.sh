#!/usr/bin/env bash
# Task 7: end-to-end test + CloudWatch Logs
set -euo pipefail; cd "$(dirname "$0")"; source env.sh

aws sqs send-message --queue-url "$QUEUE_URL" \
  --message-body "$(printf '{"bucket":"%s","key":"%s"}' "$BUCKET" "$KEY")"
sleep 15
aws logs tail "$LOG_GROUP" --since 10m
