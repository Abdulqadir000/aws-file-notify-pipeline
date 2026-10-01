import { S3Client, HeadObjectCommand } from "@aws-sdk/client-s3";
import { SNSClient, PublishCommand } from "@aws-sdk/client-sns";

const s3 = new S3Client();
const sns = new SNSClient();

const notify = async (body) => {
  const { bucket, key } = JSON.parse(body);
  if (!bucket || !key) throw new Error("Message must contain bucket and key");

  const o = await s3.send(new HeadObjectCommand({ Bucket: bucket, Key: key }));
  const details = {
    File: key,
    Bucket: bucket,
    Size: `${o.ContentLength} bytes`,
    "Content-Type": o.ContentType,
    "Last-Modified": o.LastModified.toISOString(),
    ETag: o.ETag,
    "Storage-Class": o.StorageClass ?? "STANDARD",
  };

  await sns.send(new PublishCommand({
    TopicArn: process.env.TOPIC_ARN,
    Subject: `File uploaded: ${key}`.slice(0, 100),
    Message: Object.entries(details).map(([k, v]) => `${k}: ${v}`).join("\n"),
  }));
  console.log(JSON.stringify({ status: "notified", bucket, key }));
};

// Partial batch response: only failed messages return to the queue.
export const handler = async ({ Records }) => {
  const results = await Promise.allSettled(Records.map(({ body }) => notify(body)));
  const batchItemFailures = results.flatMap((r, i) => {
    if (r.status === "fulfilled") return [];
    console.error(JSON.stringify({ status: "failed", messageId: Records[i].messageId, error: r.reason.message }));
    return [{ itemIdentifier: Records[i].messageId }];
  });
  return { batchItemFailures };
};
